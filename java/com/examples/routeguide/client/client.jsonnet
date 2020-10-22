local kube = import "external/kube_jsonnet/kube.libsonnet";
local envs = import 'prod/envs.libsonnet';
local params = std.extVar("params");
local backend_service = std.extVar("backend_service");


local main_container = kube.Container("server") {
  // Environment specific values go in a map keyed by params.env,
  // one of which will be passed into params.env
  resources: {},
  image: params.image_name,
  args: [backend_service.metadata.name, std.toString(backend_service.spec.ports[0].port)],
};

local job = kube.Job(params.name) {
  spec+: {
    selector: null,
    template+: {
      spec+: {
        containers_+: {
          gb_fe: main_container,
}}}}};


job
