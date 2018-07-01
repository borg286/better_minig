package main

import (
  "fmt"
  "context"
  "io/ioutil"
  "os/exec"
  "time"
  "testing"
)

func Test_main(t *testing.T) {
  dat, err := ioutil.ReadFile("/tmp/dat")
  if err != nil {
    return
  }
  command := string(dat)
  fmt.Sprintf(command)
  ctx, cancel := context.WithTimeout(context.Background(), 100*time.Millisecond)
  defer cancel()

  if err := exec.CommandContext(ctx, command, "4567").Run(); err != nil {
  }
  t.Fail()
}
