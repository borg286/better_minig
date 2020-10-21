local kube = import "external/kube_jsonnet/kube.libsonnet";
local envs = import 'prod/envs.libsonnet';
local params = std.extVar("params");
local backend_service = std.extVar("backend_service");
local redis_service = std.extVar("redis_service");


local main_container = kube.Container("server") {
  // Environment specific values go in a map keyed by params.env,
  // one of which will be passed into params.env
  local image = envs.splitByEnvironment(
    prod=params.image_base + "prod_tag",
    staging=params.image_base + "staging_tag",
    dev=params.image_base + "some_dev_tag",
    myns=params.local_image_name
  ),
  resources: {},
  image: image,
  args: [
    backend_service.metadata.name,
    std.toString(backend_service.spec.ports[0].port),
    redis_service.metadata.name,
    "100000",
  ],
};

local deployment = kube.Deployment(params.name) {
  spec+: {
    replicas: 1,
    template+: {
      spec+: {
        containers_+: {
          gb_fe: main_container,
}}}}};


deployment
