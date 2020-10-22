local kube = import 'external/kube_jsonnet/kube.libsonnet';
local utils = import 'jsonnet/utils.libsonnet';
local envs = import 'prod/envs.libsonnet';
local params = std.extVar("params");


local main_container = kube.Container("server") {
  resources: {},
  image: params.image_name,
  ports_+: { grpc: { containerPort: std.parseInt(params.port) } },
  envObj:: {
    PYTHONUNBUFFERED: '0',
  },
  env: utils.pairList(self.envObj),
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
