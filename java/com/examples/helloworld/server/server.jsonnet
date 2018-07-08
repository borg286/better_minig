
local kube = std.extVar("kube");
local port = std.extVar("port");
local images = std.extVar("images");

local template = kube.Deployment("java-depl") {
    spec+: {
      local my_spec = self,
      replicas: 1,
      template+: {
        spec+: {
          containers_+: {
            gb_fe: kube.Container("server") {
              resources: {},
              args: [std.toString(port)],
              ports_+: { grpc: { containerPort: port } },
}}}}}};


{
  "prod-server.json": template { 
    spec+: {
      template+: {
        spec+: {
          containers_+: {
            gb_fe+: {
              image: images["prod"],
  }}}}}},
  "staging-server.json": $["prod-server.json"] {
    spec+: {
      template+: {
        spec+: {
          containers_+: {
            gb_fe+: {
              image: images["staging"],
  }}}}}},

  "dev-server.json": $["staging-server.json"] { 
    spec+: {
      template+: {
        spec+: {
          containers_+: {
            gb_fe+: {
              image: images["dev"],
  }}}}}},
  "local-server.json": $["dev-server.json"] { 
    spec+: {
      template+: {
        spec+: {
          containers_+: {
            gb_fe+: {
              image: images["local"],
  }}}}}},

  
  "service.json": kube.Service("grpc-java") {
    target_pod: $["prod-server.json"].spec.template,
  }
}
