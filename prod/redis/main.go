package main

import (
  "os"
  "fmt"
  "time"
  "regexp"
  "bytes"
  "os/exec"
  "net"
  "errors"
  "log"
  "strconv"
  "strings"
  "github.com/gomodule/redigo/redis"
)
var allSlots string

func start() (error) {
  fmt.Println("HOSTNAME: ", os.Getenv("HOSTNAME"))
  fmt.Println("BASE: ", os.Getenv("BASE"))

  r, _ := regexp.Compile(os.Getenv("BASE") + "-([0-9]*)")
  myindex := r.FindStringSubmatch(os.Getenv("HOSTNAME"))
  fmt.Println("MyIndex: ", myindex[1])
  index, err := strconv.Atoi(myindex[1])
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
  _, err = c.Do("CONFIG", "SET", "cluster-announce-ip", os.Getenv("POD_IP"))
  if err != nil {
    return err
  }

  if index != 0 {
    seed := os.Getenv("BASE")
    ips, err := net.LookupIP(seed)
    if err != nil {
      return err
    }
    ip:= ips[0].String()

    _, err = c.Do("CLUSTER", "MEET", ip, "6379")
    if err != nil {
      return err
    }
  }

  clusterInfo, err := redis.String(c.Do("CLUSTER", "NODES"))
  if err != nil {
    return err
  }
  nodes := strings.Split(clusterInfo, "\n")
  newMaster := findMasterInNeed(nodes)
  if newMaster != "" {
    c.Do("SLAVEOF", newMaster)
  }
  os.Create("/share/lock")

  if index == 0 {
    cmd := exec.Command("/share/redis-cli", "--cluster", "fix", "127.0.0.1:6379")
    cmd.Stdin = strings.NewReader("yes")
    var out bytes.Buffer
    var stderr bytes.Buffer
    cmd.Stdout = &out
    cmd.Stderr = &stderr
    err := cmd.Run()
    fmt.Println("out:" + out.String())
    fmt.Println("err:" + stderr.String())
    if err != nil {
      return err
    }
  }
  fmt.Println("Done setting up redis")
  time.Sleep(1000000 * time.Millisecond)
  return nil
}

func findMasterInNeed(nodes []string) string {
  
  return ""
}

func main() {
  err := start()
  if err != nil {
    log.Fatal(err)
  }
}
