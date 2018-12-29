local kube = import 'external/kube_jsonnet/kube.libsonnet';
local params = std.extVar("params");
local PROD = params.envs.PROD;
local STAGING = params.envs.STAGING;
local DEV = params.envs.DEV;
local LOCAL = params.envs.LOCAL;

local main_container = kube.Container("server") {
  // Environment specific values go in a map keyed by params.env,
  // one of which will be passed into params.env
  local images = {
    PROD: params.image_base + "prod_tag",
    STAGING: params.image_base + "staging_tag",
    DEV: params.image_base + "some_dev_tag",
    LOCAL: params.local_image_name
  },
  resources: {},
  image: images[params.env],
  ports_+: { grpc: { containerPort: std.parseInt(params.port) } },
  args: ["-port", std.toString(params.port)]
};

local deployment = kube.Deployment(params.name) {
  metadata+: {namespace: params.namespace_name},
  spec+: {
    replicas: 1,
    template+: {
      spec+: {
        containers_+: {
          gb_fe: main_container,
}}}}};


deployment
