
local kube = import 'external/kube_jsonnet/kube.libsonnet';
local params = std.extVar("params");
local main_container = kube.Container("server") {
    resources: {},
    image: params.image,
    ports_+: { grpc: { containerPort: std.parseInt(params.port) } },
    # If needed I can switch on params.env to have environment-specific values.
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


deployment
