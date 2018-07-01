
local kube = std.extVar("kube");
// local image = std.extVar("image");
// local port = std.extVar("port");

local image = "us.gcr.io/not-my-project/hello-grpc-cc:staging";
local port = 50001;

{
  "server.json": kube.Deployment("cc-depl") {
    spec+: {
      local my_spec = self,
      replicas: 1,
      template+: {
        spec+: {
          containers_+: {
            gb_fe: kube.Container("server") {
              image: image,
              ports_+: { grpc: { containerPort: port } },
  }}}}}},
  
  "service.json": kube.Service("grpc-cc") {
    target_pod: $["server.json"].spec.template,
  }
}
