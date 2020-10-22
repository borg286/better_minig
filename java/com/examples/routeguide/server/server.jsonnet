
local kube = import 'external/kube_jsonnet/kube.libsonnet';
local envs = import 'prod/envs.libsonnet';
local params = std.extVar("params");

local main_container = kube.Container("server") {
  // Environment specific values go in a map keyed by params.env,
  // one of which will be passed into params.env
  resources: {},
  image: params.image_name,
  ports_+: { grpc: { containerPort: std.parseInt(params.port) } },
  args: [std.toString(params.port)]
};

local deployment = kube.Deployment(params.name) {
  spec+: {
    replicas: 1,
    template+: {
      spec+: {
        containers_+: {
          gb_fe: main_container,
}}}}};


{
  "server.json": deployment
}
