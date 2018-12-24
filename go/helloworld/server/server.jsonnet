local kube = import 'external/kube_jsonnet/kube.libsonnet';
local params = std.extVar("params");

local template = kube.Deployment(params.name) {
    spec+: {
      local my_spec = self,
      replicas: 1,
      template+: {
        spec+: {
          containers_+: {
            gb_fe: kube.Container("server") {
              args: ["-port", std.toString(params.port)],
              ports_+: { grpc: { containerPort: params.port } },
}}}}}};


{
  "prod-server.json": template { 
    spec+: {
      template+: {
        spec+: {
          containers_+: {
            gb_fe+: {
              image: params.images.prod,
  }}}}}},
  "staging-server.json": $["prod-server.json"] {
    spec+: {
      template+: {
        spec+: {
          containers_+: {
            gb_fe+: {
              image: params.images.staging,
  }}}}}},

  "dev-server.json": $["staging-server.json"] { 
    spec+: {
      template+: {
        spec+: {
          containers_+: {
            gb_fe+: {
              image: params.images.dev,
  }}}}}},
  "local-server.json": $["dev-server.json"] { 
    spec+: {
      template+: {
        spec+: {
          containers_+: {
            gb_fe+: {
              image: params.images["local"],
  }}}}}},
}
