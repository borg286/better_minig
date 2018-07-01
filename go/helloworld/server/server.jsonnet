
local kube = std.extVar("kube");
// local image = std.extVar("image");
// local port = std.extVar("port");

local image = "us.gcr.io/not-my-project/hello-grpc-go:staging";
local port = 50001;

{
  "server.json": kube.Deployment("frontend") {
    spec+: {
      local my_spec = self,
      replicas: 1,
      template+: {
        spec+: {
          containers_+: {
            gb_fe: kube.Container("my-container") {
              image: image,
              ports_+: { grpc: { containerPort: port } },
  }}}}}},
  
  "service.json": kube.Service("frontend") {
    target_pod: $["frontend_deployment.json"].spec.template,
  }
}
