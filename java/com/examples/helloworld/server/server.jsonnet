
local kube = std.extVar("kube");
// local image = std.extVar("image");
// local port = std.extVar("port");

local image = "us.gcr.io/not-my-project/hello-grpc:staging";
local port = 50001;

{
  "frontend_deployment.json": kube.Deployment("frontend") {
    spec+: {
      local my_spec = self,
      replicas: 1,
      template+: {
        spec+: {
          containers_+: {
            gb_fe: kube.Container("my-container") {
              image: image,
              args: [std.toString(port)],
              ports_+: { grpc: { containerPort: port } },
  }}}}}},
  
  "service_deployment.json": kube.Service("frontend") {
    target_pod: $["frontend_deployment.json"].spec.template,
  }
}
