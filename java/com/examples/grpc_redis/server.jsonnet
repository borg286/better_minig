
local kube = import 'external/kube_jsonnet/kube.libsonnet';
local redis = import 'jsonnet/redis.libsonnet';
local params = std.extVar("params");

local redis_server = redis.Server(params.name + "-redis");
local redis_service = redis.Service(params.name + "-redis", redis_server.spec.template);

local template = kube.Deployment(params.name) {
    spec+: {
      local my_spec = self,
      replicas: 1,
      template+: {
        spec+: {
          containers_+: {
            gb_fe: kube.Container("server") {
              resources: {},
              args: [
                  params.port, redis_service.metadata.name,
                  "-port", params.port,
                  "-redis_service", redis_service.metadata.name,
                  "-redis_port", std.toString(redis_service.spec.ports[0].port)],
              ports_+: { grpc: { containerPort: std.parseInt(params.port) } },
}}}}}};


{
  "redis.json": redis_server,
  "redis-svc.json": redis_service,
  "prod-server.json": template { 
    spec+: {
      template+: {
        spec+: {
          containers_+: {
            gb_fe+: {
              image: params.images.prod,
  }}}}}},
  "staging-server.json": $["prod-server.json"] {
    spec+: {
      template+: {
        spec+: {
          containers_+: {
            gb_fe+: {
              image: params.images.staging,
  }}}}}},

  "dev-server.json": $["staging-server.json"] { 
    spec+: {
      template+: {
        spec+: {
          containers_+: {
            gb_fe+: {
              image: params.images.dev,
  }}}}}},
  "local-server.json": $["dev-server.json"] { 
    spec+: {
      template+: {
        spec+: {
          containers_+: {
            gb_fe+: {
              # it seems .local means something different in jsonnet
              image: params.images["local"],
  }}}}}},
}
