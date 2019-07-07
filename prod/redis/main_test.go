package main

import (
  "testing"
  "github.com/borg286/prod/redis"
)

func TestCleanStart(t *testing.T) {

  // Start with node 0 wth a clean disk
  status1 := main.Status{
    IP: "1.2.3.4",
    ID: "",
    View: nil,
    Index: 0,
    Peers: nil,
    RootView: nil,
  }
  if !status1.ShouldFlushAndRestart() {
    t.Errorf("We should have flushed and restarted")
  }

  // Redis 0 now starts up in cluster mode but no slots are assigned
  m1 := main.Node{
    Id: "m1id",
    Ip: "1.2.3.4",
    Port: "6379",
    Flags: map[string]bool{"master":true},
    Master: "-",
    Ping_sent: "0",
    Pong_recv: "0",
    Config_epoch: "1",
    Link_state: "connected",
    HasSlots: false,
    Slaves: map[string]bool{},
  }
  status1.View = &main.View{
  	ClusterOk: false,
    Nodes: map[string]main.Node{
      m1.Id: m1,
    },
  }
  status1.RootView = status1.View
  status1.ID = m1.Id
  if status1.ShouldReplicateRoot(false) {
    t.Errorf("Node 0 should not be replicating to itself")
  }

  // sidecar should now try to fix the cluster, which assigns slots
  m1.HasSlots = true
  status1.RootView.ClusterOk = true

  // node 0 starts up with a clean disk
  status2 := main.Status{
    IP: "1.2.3.5",
    ID: "",
    View: nil,
    RootView: status1.RootView,
    Index: 1,
    Peers: map[string]*main.View{
      // DNS lookup on the service shows the view of the rest of the fleet
      m1.Id: status1.View,
    },
  }
  t.Log(status2)
  if !status2.ShouldFlushAndRestart() {
    t.Errorf("We should have flushed and restarted")
  }

  // node 1 now starts up in cluster mode having met nobody


  s1 := main.Node{
    Id: "s1id",
    Ip: "1.2.3.5",
    Port: "6379",
    Flags: map[string]bool{"master":true},
    Master: "-",
    Ping_sent: "0",
    Pong_recv: "0",
    Config_epoch: "1",
    Link_state: "connected",
    HasSlots: false,
    Slaves: map[string]bool{},
  }
  status2.View = &main.View{
    Nodes: map[string]main.Node{
      // we omit m1 because it hasn't met the cluster yet.
      s1.Id: s1,
    },
  }
  status2.RootView = status1.RootView
  status2.ID = s1.Id
  if !status2.ShouldReplicateRoot(false) {
    t.Errorf("Node 1 should replicate from node 0")
  }

  //The rest of the fleet will act like m2 for starting from a clean slate.
}


func TestUpgrade(t *testing.T) {

  // Start with node 0 with nodes.conf filled out and the rest of the fleet answering
  // Redis 0 has slots and slaves

  s1 := main.Node{
    Id: "s1id",
    Ip: "1.2.3.5",
    Port: "6379",
    Flags: map[string]bool{"slave":true},
    Master: "m1id",
    Ping_sent: "1",
    Pong_recv: "1",
    Config_epoch: "1",
    Link_state: "connected",
    HasSlots: false,
    Slaves: map[string]bool{},
  }


  m1 := main.Node{
    Id: "m1id",
    Ip: "1.2.3.4",
    Port: "6379",
    Flags: map[string]bool{"master":true},
    Master: "-",
    Ping_sent: "0",
    Pong_recv: "0",
    Config_epoch: "1",
    Link_state: "connected",
    HasSlots: true,
    Slaves: map[string]bool{s1.Id: true},
  }

  // master 1's view is populated from nodes.conf
  m1view := main.View{
    Myid: m1.Id,
    ClusterOk: false,
    Nodes: map[string]main.Node{
      m1.Id: m1,
      s1.Id: s1,
    },
  }
  s1view := main.View{
    Myid: s1.Id,
    ClusterOk: true,
    Nodes: map[string]main.Node{
      m1.Id: m1,
      s1.Id: s1,
    },
  }

  status1 := main.Status{
    IP: m1.Ip,
    ID: m1.Id,
    View: &m1view,
    RootView: nil,
    Index: 0,
    // master 1's peers should be up
    Peers: map[string]*main.View{
      m1.Ip: nil,
      s1.Ip: &s1view,
    },
  }
  t.Log(status1)
  if status1.ShouldFlushAndRestart() {
    t.Errorf("Node 0 should not be flushing everything when cluster is consistent.")
  }

  // m1 should have started up and read nodes.conf and resumed it's place in the cluster
  // the cluster should be ok and it should be listed in the list of IPs in the dns lookup
  m1view.ClusterOk = true
  status1.Peers[m1.Id] = &m1view
  status1.RootView = &m1view
  if status1.ShouldReplicateRoot(false) {
    t.Errorf("Node 0 should not be replicating to itself")
  }

  // slave 1 is now upgraded
  // status2 is populated from the nodes.conf on disk and doing the DNS on the service
  status2 := main.Status{
    IP: s1.Ip,
    ID: s1.Id,
    View: &s1view,
    RootView: &m1view,
    Index: 1,
    // slave 1's peers should be up
    Peers: map[string]*main.View{
      m1.Ip: &m1view,
      s1.Ip: nil,
    },
  }
  if status2.ShouldFlushAndRestart() {
    t.Errorf("Node 1 should not be flushing everything when cluster is consistent.")
  }
  status2.Peers[s1.Ip] = &s1view
  if status1.ShouldReplicateRoot(false) {
    t.Errorf("Node 1 should not be replicating as it is already set up")
  }
}

func TestPostDelete(t *testing.T) {

  // Start with node 0 with a stale nodes.conf filled out and the rest of the fleet not answering

  s1 := main.Node{
    Id: "s1oldid",
    Ip: "1.2.3.5",
    Port: "6379",
    Flags: map[string]bool{"slave":true},
    Master: "m1id",
    Ping_sent: "1",
    Pong_recv: "1",
    Config_epoch: "1",
    Link_state: "disconnected",
    HasSlots: false,
    Slaves: map[string]bool{},
  }


  m1 := main.Node{
    Id: "m1oldid",
    Ip: "1.2.3.4",
    Port: "6379",
    Flags: map[string]bool{"master":true},
    Master: "-",
    Ping_sent: "0",
    Pong_recv: "0",
    Config_epoch: "1",
    Link_state: "connected",
    HasSlots: true,
    Slaves: map[string]bool{s1.Id: true},
  }

  // master 1's view is populated from a stale nodes.conf
  m1view := main.View{
    Myid: m1.Id,
    ClusterOk: false,
    Nodes: map[string]main.Node{
      m1.Id: m1,
      s1.Id: s1,
    },
  }

  status1 := main.Status{
    IP: m1.Ip,
    ID: m1.Id,
    View: &m1view,
    Index: 0,
    // node 0 is first one up, so no one else is answering
    Peers: nil,
  }
  if !status1.ShouldFlushAndRestart() {
    t.Errorf("Node 0 should be flushing everything when cluster is not anwering on bootup.")
  }

  // m1 should have started up and treated an empty data directory as a clean start
  // It should then have fixed itself
  // the cluster should be ok and it should be listed in the list of IPs in the dns lookup

  m1new := main.Node{
    Id: "m1newid",
    Ip: "1.2.3.4",
    Port: "6379",
    Flags: map[string]bool{"master":true},
    Master: "-",
    Ping_sent: "0",
    Pong_recv: "0",
    Config_epoch: "1",
    Link_state: "connected",
    HasSlots: true,
    Slaves: map[string]bool{},
  }

  // master 1's view is populated from a stale nodes.conf
  m1newview := main.View{
    Myid: m1new.Id,
    ClusterOk: true,
    Nodes: map[string]main.Node{
      m1new.Id: m1new,
    },
  }
  status1new := main.Status{
    IP: m1new.Ip,
    ID: m1new.Id,
    View: &m1newview,
    Index: 0,
    // node 0 is first one up, so no one else is answering
    Peers: map[string]*main.View{
    	m1new.Id: &m1newview,
    },
  }
  if status1new.ShouldReplicateRoot(false) {
    t.Errorf("Node 0 should not be replicating to itself")
  }
  // master 1's view is populated from a stale nodes.conf
  s1view := main.View{
    Myid: m1.Id,
    ClusterOk: false,
    Nodes: map[string]main.Node{
      m1.Id: m1,
      s1.Id: s1,
    },
  }
  // slave 1 is now starting but has stale nodes.conf
  // status2 is populated from the stale nodes.conf on disk and doing the DNS on the service
  status2 := main.Status{
    IP: s1.Ip,
    ID: s1.Id,
    View: &s1view,
    RootView: &m1newview,
    Index: 1,
    // slave 1's peers should be up
    Peers: map[string]*main.View{
      m1.Ip: &m1view,
    },
  }
  if !status2.ShouldFlushAndRestart() {
    t.Errorf("Node 1 should be flushing everything when stale nodes.conf does not match majority of active masters.")
  }
  // s1 should have a clean slate and should make itself a replica of node 0
  s1new := main.Node{
    Id: "s1newid",
    Ip: "1.2.3.5",
    Port: "6379",
    Flags: map[string]bool{"master":true},
    Master: "-",
    Ping_sent: "1",
    Pong_recv: "1",
    Config_epoch: "1",
    Link_state: "connected",
    HasSlots: false,
    Slaves: map[string]bool{},
  }
  s1newview := main.View{
    Myid: s1new.Id,
    ClusterOk: false,
    Nodes: map[string]main.Node{
      s1new.Id: s1new,
    },
  }
  status2new := main.Status{
    IP: s1new.Ip,
    ID: s1new.Id,
    View: &s1newview,
    RootView: &m1newview,
    Index: 1,
    // slave 1's peers should be up
    Peers: map[string]*main.View{
      m1new.Ip: &m1newview,
    },
  }
  t.Log("=============")
  if !status2new.ShouldReplicateRoot(false) {
    t.Errorf("Node 1 should be replicating Root after cleaning disk")
  }
}
