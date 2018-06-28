
local kube = std.extVar("kube");

{
  "frontend_deployment.json": kube.Deployment("frontend") {
    spec+: {
      local my_spec = self,
      replicas: 1,
      template+: {
        spec+: {
          containers_+: {
            gb_fe: kube.Container("gb-frontend") {
              image: "gcr.io/google-samples/gb-frontend:v4",
              ports_+: { grpc: { containerPort: 50001 } },
  }}}}}},
  
  "service_deployment.json": kube.Service("frontend") {
    target_pod: $["frontend_deployment.json"].spec.template,
  }
}
