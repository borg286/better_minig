
local kube = import 'external/kube_jsonnet/kube.libsonnet';
local envs = import 'prod/envs.libsonnet';
local params = std.extVar("params");
local redis_service = std.extVar("redis");

local main_container = kube.Container("server") {
  local image = envs.splitByEnvironment(
    prod=params.image_base + "prod_tag",
    staging=params.image_base + "staging_tag",
    dev=params.image_base + "some_dev_tag",
    myns=params.local_image_name
  ),
  resources: {},
  image: image,
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
  spec+: {
    replicas: 1,
    template+: {
      spec+: {
        containers_+: {
          default: main_container,
          health: health_sidecar,
}}}}};

{
  ["server.json"]: deployment,
}

