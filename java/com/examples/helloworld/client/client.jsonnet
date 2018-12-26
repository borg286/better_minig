
local kube = import "external/kube_jsonnet/kube.libsonnet";
local backend_service = std.extVar("backend_service");
local params = std.extVar("params");
local env = params.env;


std.prune(kube.Deployment(params.name) {
  spec+: {
    template+: {
      spec+: {
        containers_+: {
          foo_cont: kube.Container("client") {
            image: params.image,
            # I can switch on params.env to get environment specific configuration.
            args: [backend_service.metadata.name,  std.toString(backend_service.spec.ports[0].port)],
          },
        },
      },
    },
  },
})
