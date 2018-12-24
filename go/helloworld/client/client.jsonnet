local kube = import 'external/kube_jsonnet/kube.libsonnet';
local backend_service = std.extVar("backend_service");
local params = std.extVar("params");

local template = std.prune(kube.Deployment(params.name) {
  spec+: {
    template+: {
      spec+: {
        containers_+: {
          foo_cont: kube.Container("client") {
            image: "will be replaced",
            args: ["-grpc_server_domain", backend_service.metadata.name, "-grpc_server_port", std.toString(backend_service.spec.ports[0].port)],
          },
        },
      },
    },
  },
});



{
  "prod-client.json": template {
    spec+:{template+:{spec+:{containers:[super.containers[0]{image: params.images.prod}]}}}
  },
  "staging-client.json": template {
    spec+:{template+:{spec+:{containers:[super.containers[0]{image: params.images.staging}]}}}
  },
  "dev-client.json": template {
    spec+:{template+:{spec+:{containers:[super.containers[0]{image: params.images.dev}]}}}
  },
  "local-client.json": template {
    spec+:{template+:{spec+:{containers:[super.containers[0]{image: params.images["local"]}]}}}
  },

}
