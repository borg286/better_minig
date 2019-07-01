package main

import (
  "os"
  "fmt"
  "time"
  "regexp"
  "bytes"
  "os/exec"
  "errors"
  "log"
  "net"
  "strconv"
  "strings"
  "github.com/gomodule/redigo/redis"
)
var allSlots string

func start() (error) {
  fmt.Println("This is versin  2")
  fmt.Println("HOSTNAME: ", os.Getenv("HOSTNAME"))
  fmt.Println("BASE: ", os.Getenv("BASE"))

  r, _ := regexp.Compile(os.Getenv("BASE") + "-([0-9]*)")
  myindex := r.FindStringSubmatch(os.Getenv("HOSTNAME"))
  index, err := strconv.Atoi(myindex[1])
  fmt.Println("index: ", index)
  if err != nil {
    return err
  }

  fmt.Println("Trying to connect to Redis")
  var c redis.Conn
  for err:= errors.New("dummy"); err != nil;  c, err = redis.Dial("tcp", "127.0.0.1:6379", redis.DialReadTimeout(1 * time.Second)) {
    fmt.Println("Redis isn't up yet. Waiting 1s")
    time.Sleep(1 * time.Second)
  }
  fmt.Println("Connection to local redis established")
  defer c.Close()

  // check if this node is fresh and hasn't been put into the cluster
  nodesInfo, err := redis.String(c.Do("CLUSTER", "NODES"))
  if err != nil {
    return err
  }
  nodes := strings.Split(nodesInfo, "\n")
  fmt.Println("Nodes: ", nodes)
  n := 0
  for _, elem := range nodes {
    if len(elem) > 3 {
      n++
    }
  }
  fmt.Println("Length of nodes before meeting is ", n)
  shouldReplicateNode0 := n <= 1

  seed := fmt.Sprintf("%s-0.%s.%s.svc.cluster.local", os.Getenv("BASE"),os.Getenv("BASE"),os.Getenv("POD_NAMESPACE"))
  fmt.Println("Seed: ", seed)
  ips, err := net.LookupIP(seed)
  if err != nil {
    return err
  }
  ip := ips[0].String()
  fmt.Println("Meeting ", ip)
  _, err = c.Do("CLUSTER", "MEET", ip, "6379")
  if err != nil {
    return err
  }

  if shouldReplicateNode0 && index != 0 {
    // First get ID of node 0
    var c2 redis.Conn
    c2, err = redis.Dial("tcp", ip + ":6379", redis.DialReadTimeout(2 * time.Second))
    if err != nil {
      // try to undo havig met the cluster as a master (default)
      c.Do("CLUSTER", "RESET", "SOFT")
      return err
    }
    rootClusterNodes, err := redis.String(c2.Do("CLUSTER", "NODES"))
    if err != nil {
      return err
    }
    clusterNodes, err := redis.String(c.Do("CLUSTER", "NODES"))
    if err != nil {
      return err
    }

    fmt.Println("====Root cluster Nodes====")
    fmt.Println(rootClusterNodes)
    fmt.Println("====My cluster Nodes====")
    fmt.Println(clusterNodes)

    seedId := strings.Split(grep("myself", strings.Split(rootClusterNodes, "\n"))[0], " ")[0]
    fmt.Println("Attempting to be a slave of %s", seedId)
    _, err = c.Do("CLUSTER", "REPLICATE", seedId)
    if err != nil {
      return err
    }
  }

  if index == 0 {
    fixCluster(c)
    fixTicker := time.NewTicker(5 * time.Second)
    for {
      select {
      case <-fixTicker.C:
        fixCluster(c)
      }
    }
  } else {
    time.Sleep(10000000*time.Second)
  }
  return nil
}

func grep(filter string, lines []string) []string {
  ret := []string{}
  for _, line := range lines {
    if strings.Contains(line, filter) {
      ret = append(ret, line)
    }
  }
  return ret
}

type node struct {
  id, ip, port, master, ping_sent, pong_recv, config_epoch, link_state string
  flags []string
  hasSlots bool
  slaves []*node
}

func Filter(vs []node, f func(node) bool) []node {
    vsf := []node{}
    for _, v := range vs {
        if f(v) {
            vsf = append(vsf, v)
        }
    }
    return vsf
}

func parseNodes(nodeLines []string) []node {
  var nodes []node
  for _, line := range nodeLines {
    parts := strings.Split(line, " ")
    if len(parts) < 8 {
      continue
    }
    ipPortParts := strings.Split(parts[1], ":")
    nodes = append(nodes, node{
      id:parts[0],
      ip: ipPortParts[0],
      port: ipPortParts[1],
      flags: strings.Split(parts[2], ","),
      master: parts[3],
      ping_sent: parts[4],
      pong_recv: parts[5],
      config_epoch: parts[6],
      link_state: parts[7],
      hasSlots: len(parts) > 8,
      slaves: []*node{},
    })
  }
  return nodes
}


func fixCluster(c redis.Conn) {

  clusterInfo, err := redis.String(c.Do("CLUSTER", "INFO"))
  if err != nil {
    fmt.Println("Unable to fetch cluster info")
    return
  }
  fmt.Println(clusterInfo)
  clusterInfoLines := strings.Split(clusterInfo, "\n")
  if clusterInfoLines[0] != "cluster_state:ok" {
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

func findMasterInNeed(nodes []string) string {
  masters := 0
  slaves := 0
  n := len(nodes)
  anyMaster := ""  // Cluster redis can shift slaves around to non-replicated masters.
  for i:=0; i<len(nodes); i++ {
    parts := strings.Split(nodes[i], " ")
    fmt.Println("==================")
    for j:=0; j<len(parts); j++ {
      fmt.Println(parts[j])
    }
    if len(parts) < 2 {
      continue
    }
    mastership := parts[2]
    if strings.Contains(mastership, "master") && !strings.Contains(mastership, "myself") {
      masters+=1
      anyMaster = strings.Replace(parts[1], ":", " ", 1)  //  SLAVEOF can't handle the : but needs <space> instead
    }
    if strings.Contains(mastership, "slave") {
      if strings.Contains(mastership, "myself") {
        return ""  //I am already a slave as configured by the stateful nodes.conf file on disk
      }
      slaves+=1
    }
  }
  if masters > n/2 {
    return anyMaster
  }
  return ""
}

func main() {
  err := start()
  if err != nil {
    log.Fatal(err)
  }
}
