package main

import (
  "os"
  "fmt"
  "time"
  "regexp"
  "bytes"
  "bufio"
  "os/exec"
  "errors"
  "log"
  "net"
  "strconv"
  "strings"
  "github.com/gomodule/redigo/redis"
)


type Node struct {
  Id string `json:"Id"`
  Ip string `json:"Ip"`
  Port string `json:"Port"`
  Master string `json:"Master"`
  Ping_sent string `json:"Ping_sent"`
  Pong_recv string `json:"Pong_recv"`
  Config_epoch string `json:"Config_epoch"`
  Link_state string `json:"Link_state"`
  Flags map[string]bool `json:"Flags"`
  HasSlots bool `json:"hasSlots"`
  Slaves map[string]bool `json:"Slaves"`
}


func (n *Node) String() string {
  return fmt.Sprintf("%+v", n)
}

type View struct {
  Myid string
  ClusterOk bool
  Nodes map[string]Node
}

type Status struct {
  IP string
  ID string
  View *View
  RootView *View
  Index int
  Peers map[string]*View
}

func (s Status) FillOutPeers() {
  
}

func (s Status) ShouldFlushAndRestart() bool {
  if s.Index == 0 {
    if s.Peers == nil || len(s.Peers) == 0{
      return true
    }
  } else {
    if s.View == nil {
      // No nodes.conf on disk, also means we shouldn't have dump.rdb, so clean any that may be there
      return true
    }
    if MasterIDsAreEqual(*s.RootView, *s.View) {
      // my nodes.conf aligns with the root's view
      return false
    } else {
      // Root is treated as an authority on the state of the cluster.
      // As a consequence, if root is messed up and this task undergoes an upgrade, all data is thrown out
      return true
    }
  }
  return false
}


func (s Status) ShouldReplicateRoot(debug bool) bool {
  if s.Index == 0 {
    return false
  }
  if debug {
    fmt.Println("===============")
    fmt.Println("State", s)
    fmt.Println("MyView", *s.View)
    fmt.Println("RootView", *s.RootView)
    fmt.Println("My node", s.View.Nodes[s.ID])
  }
  if !s.RootView.ClusterOk {
    return false
  }

  if s.View.Nodes[s.ID].HasSlots {
    return false
  }
  return true
}



func (v View) getMasters() map[string]bool {
  masters := map[string]bool{}

  for id, node := range v.Nodes {
    if node.Flags["master"] {
      masters[id] = true
    }
  }
  return masters
}

func MasterIDsAreEqual(v1 View, v2 View) bool {
  v1masters := v1.getMasters()
  v2masters := v2.getMasters()

  for id, _ := range v1masters {
    if _, ok := v2masters[id]; !ok {
      return false
    }
  }
  for id, _ := range v2masters {
    if _, ok := v1masters[id]; !ok {
      return false
    }
  }
  return true
}


func ParseNode(line string) (*Node, bool) {
  parts := strings.Split(line, " ")
  if len(parts) < 8 {
    return nil, false
  }
  ipPortParts := strings.Split(parts[1], ":")
  flags := map[string]bool {}
  hasMyself := false
  for _, flag := range strings.Split(parts[2], ",") {
    if flag == "myself" {
      hasMyself = true
      continue
    }
    flags[flag] = true
  }
  return &Node{
    Id:parts[0],
    Ip: ipPortParts[0],
    Port: ipPortParts[1],
    Flags: flags,
    Master: parts[3],
    Ping_sent: parts[4],
    Pong_recv: parts[5],
    Config_epoch: parts[6],
    Link_state: parts[7],
    HasSlots: len(parts) > 8,
    Slaves: map[string]bool{},
  }, hasMyself
}


func fixCluster(c redis.Conn) {
  clusterInfo, err := redis.String(c.Do("CLUSTER", "INFO"))
  if err != nil {
    fmt.Println("Unable to fetch cluster info")
    return
  }
  fmt.Println(clusterInfo)
  // TODO: I removed grep for cluster_state:ok. Put it back
  if 0 < len(strings.Split(clusterInfo, "\n")) {
    fmt.Println("Attempting to fix the cluster")
    cmd := exec.Command("/share/redis-cli", "--cluster", "fix", "127.0.0.1:6379")
    cmd.Stdin = strings.NewReader("yes")
    var out bytes.Buffer
    var stderr bytes.Buffer
    cmd.Stdout = &out
    cmd.Stderr = &stderr
    cmd.Run()
    fmt.Println("out:" + out.String())
    fmt.Println("err:" + stderr.String())
   }
}

func isClusterOk(c redis.Conn) bool {
  clusterInfo, err := redis.String(c.Do("CLUSTER", "INFO"))
  if err != nil {
    return false
  }
  for _, line := range strings.Split(clusterInfo, "\n") {
    if strings.Contains(line, "cluster_state:ok") {
      return true
    }
    if strings.Contains(line, "cluster_state:fail") {
      return false
    }
  }
  return false
}

func getPeers() map[string]*View {
  ips, err := net.LookupIP(os.Getenv("BASE"))
  if err != nil {
    fmt.Println("DNS lookup on service failed", err)
    return nil
  }
  peers := map[string]*View {}
  for _, ip := range ips {
    peers[ip.String()] = nil
  }
  return peers
}

func getViewFromConnection(c redis.Conn) *View {
  nodesInfo, err := redis.String(c.Do("CLUSTER", "NODES"))
  if err != nil {
    fmt.Println(err)
    return nil
  }

  view := getViewFromStrings(strings.Split(nodesInfo, "\n"))
  view.ClusterOk = isClusterOk(c)
  return view
}

func getViewFromStrings(lines []string) *View {
  nodes := map[string]Node{}
  var self *Node
  for _, line := range lines {
    if len(line) > 4 {
      node, isSelf := ParseNode(line)
      if isSelf {
        self = node
      }
      nodes[node.Id] = *node
    }
  }

  view := &View{
    Myid: self.Id,
    Nodes: nodes,
    ClusterOk: false,
  }
  return view
}

func getViewFromFile() *View {
  file, err := os.Open("/data/nodes.conf")
  if err != nil {
      return nil
  }
  defer file.Close()

  scanner := bufio.NewScanner(file)
  lines := []string{}
  for scanner.Scan() {
      lines = append(lines, scanner.Text())
  }
  view := getViewFromStrings(lines)
  return view
}

func getIndex() int {
  r, _ := regexp.Compile(os.Getenv("BASE") + "-([0-9]*)")
  myindex := r.FindStringSubmatch(os.Getenv("HOSTNAME"))
  index, _ := strconv.Atoi(myindex[1])
  return index
}

func makeConnection(index int) (redis.Conn, error) {
  var ip string 
  var c redis.Conn
  seed := fmt.Sprintf("%s-%d.%s.%s.svc.cluster.local", os.Getenv("BASE"), index, os.Getenv("BASE"),os.Getenv("POD_NAMESPACE"))
  ips, err := net.LookupIP(seed)
  if err != nil {
    return nil, err
  }
  ip = ips[0].String()
  
  for err:= errors.New("dummy"); err != nil;  c, err = redis.Dial("tcp", ip + ":6379", redis.DialReadTimeout(1 * time.Second)) {
    fmt.Println("Redis at " + ip + " isn't up yet. Waiting 1s")
    time.Sleep(1 * time.Second)
  }
  return c, nil
}

func prestart() (error) {
  s := Status{
    IP: os.Getenv("POD_IP"),
    Index: getIndex(),
    Peers: getPeers(),
  }
  v := getViewFromFile()
  if v != nil {
    s.ID = v.Myid
    s.View = v
  }
  if s.Index > 0 {
    c, err := makeConnection(0)
    if err != nil {
      return err
    }
    defer c.Close()
    s.RootView = getViewFromConnection(c)
    fmt.Println("RootView", s.RootView)
  }

  
  fmt.Println("View", v)
  fmt.Println("Status", s)

  if s.ShouldFlushAndRestart() {
    err := os.Remove("/data/nodes.conf")
    if err != nil {
      return err
    }
    err = os.Remove("/data/dump.rdb")
    if err != nil {
      return err
    }
  }
  return nil
}

func start() (error) {
  s := Status{
    IP: os.Getenv("POD_IP"),
    Index: getIndex(),
    Peers: getPeers(),
  }
  c, err := makeConnection(s.Index)
  if err != nil {
    return err
  }
  defer c.Close()
  s.View = getViewFromConnection(c)
  s.ID = s.View.Myid
  croot, err := makeConnection(0)
  if err != nil {
    return err
  }
  defer croot.Close()
  s.RootView = getViewFromConnection(croot)


  if s.Index == 0 {
    fixCluster(c)
    fixTicker := time.NewTicker(5 * time.Second)
    exaltTheSpareTicker := time.NewTicker(10 * time.Second)
    for {
      select {
      case <-fixTicker.C:
        fixCluster(c)
      case <-exaltTheSpareTicker.C:
        exaltTheSpare(c)
      }
    }
  } else {
    time.Sleep(10000000*time.Second)
  }
  return nil
}

func exaltTheSpare(c redis.Conn) {

}

func main() {
  if os.Args[1] == "sidecar" {
    err := start()
    if err != nil {
      log.Fatal(err)
    }
  } else if os.Args[1] == "prestart" {
    err := prestart()
    if err != nil {
      fmt.Println(err)
    }
  }
}
