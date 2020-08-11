
local kube = import 'external/kube_jsonnet/kube.libsonnet';
local envs = import 'prod/envs.libsonnet';
local params = std.extVar("params");
local redis_service = std.extVar("redis");

local main_container = kube.Container("server") {
  // Environment specific values go in a map keyed by params.env,
  // one of which will be passed into params.env
  local images = envs.toEnvironmentMap(
    prod=params.image_base + "prod_tag",
    staging=params.image_base + "staging_tag",
    dev=params.image_base + "some_dev_tag",
    myns=params.local_image_name
  ),
  resources: {},
  image: images[params.env],
  ports_+: { grpc: { containerPort: std.parseInt(params.port) } },
  args: [std.toString(params.port), redis_service.metadata.name]
};

local health_sidecar = kube.Container("health") {
  resources: {},
  image: "amothic/grpc-health-probe:latest",
  securityContext: {capabilities: {add: ["SYS_PTRACE"]}},
  // This image doesn't have a way to sleep, so use the only binary and make it wait forever.
  args: ["-addr=:9011", "-connect-timeout=999999999s"],
  livenessProbe: {exec: {command: ["/bin/grpc_health_probe", "-addr=:" + params.port]}},
  readinessProbe: {exec: {command: ["/bin/grpc_health_probe", "-addr=:" + params.port]}},
};

local deployment = kube.Deployment(params.name) {
  metadata+: {namespace: envs.getName(params.env)},
  spec+: {
    replicas: 1,
    template+: {
      spec+: {
        containers_+: {
          default: main_container,
          health: health_sidecar,
}}}}};

{
  [params.env + "-server.json"]: deployment,
}

