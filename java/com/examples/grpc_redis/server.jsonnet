
local kube = import 'external/kube_jsonnet/kube.libsonnet';
local redis = import 'jsonnet/redis.libsonnet';
local params = std.extVar("params");
local server_filename = params.env + "-server.json";

local redis_server = redis.Server(params.name + "-redis", params.env);
local redis_service = redis.Service(params.name + "-redis", redis_server.spec.template, params.env);
local redis_server_filename = params.env + "-redis.json";
local redis_service_filename = params.env + "-redis-svc.json";

local main_container = kube.Container("server") {
    resources: {},
    ports_+: { grpc: { containerPort: std.parseInt(params.port) } },
    image: params.image,
    args: [
        params.port, redis_service.metadata.name,
        "-port", params.port,
        "-redis_service", redis_service.metadata.name,
        "-redis_port", std.toString(redis_service.spec.ports[0].port)]};

{
  [server_filename]: kube.Deployment(params.name) {
    spec+: {
      replicas: 1,
      template+: {
        spec+: {
          containers_+: {
            gb_fe: main_container
  }}}}},
  [redis_server_filename]: redis_server,
  [redis_service_filename]: redis_service,
}

