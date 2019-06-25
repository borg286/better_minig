package main

import (
  "os"
  "fmt"
  "time"
  "regexp"
  "net"
  "errors"
  "log"
  "github.com/gomodule/redigo/redis"
)

func main() {
  fmt.Println("HOSTNAME: ", os.Getenv("HOSTNAME"))
  fmt.Println("BASE: ", os.Getenv("BASE"))

  r, _ := regexp.Compile(os.Getenv("BASE") + "-([0-9]*)")
  myindex := r.FindStringSubmatch(os.Getenv("HOSTNAME"))
  fmt.Println("MyIndex: ", myindex[1])
  fmt.Println("Trying to connect to Redis")
  var c redis.Conn
  for err:= errors.New("dummy"); err != nil;  c, err = redis.Dial("tcp", "127.0.0.1:6379", redis.DialReadTimeout(1 * time.Second)) {
    fmt.Println("Redis isn't up yet. Waiting 1s")
    time.Sleep(1 * time.Second)
  }
  defer c.Close()
  _, err := c.Do("CONFIG", "SET", "cluster-announce-ip", os.Getenv("POD_IP"))
  if err != nil {
    fmt.Println("bad attempt at doing the config");
    log.Fatal("Unable to set the config", err);
  }


  if myindex[1] == "0" {
    os.Create("/lock")
  } else {
    seed := os.Getenv("BASE")
    ips, err := net.LookupIP(seed)
    if err != nil {
      fmt.Fprintf(os.Stderr, "Could not get IPs for %s: %v\n", seed, err)
      os.Exit(1)
    }
    ip:= ips[0].String()

    _, err = c.Do("CLUSTER", "MEET", ip, "6379")
    if err != nil {
      fmt.Println("Error meeting " + ip, err);
    }
    os.Create("/lock")
  }

  fmt.Println("Done setting up redis")
  time.Sleep(1000000 * time.Millisecond)
}
