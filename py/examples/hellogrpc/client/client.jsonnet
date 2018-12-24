local kube = import "external/kube_jsonnet/kube.libsonnet";
local utils = import "jsonnet/utils.libsonnet";
local backend_service = std.extVar("backend_service");
local params = std.extVar("params");


local template = std.prune(kube.Deployment(params.name) {
  spec+: {
    template+: {
      spec+: {
        containers_+: {
          foo_cont: kube.Container("client") {
            image: "will be replaced",
            envObj:: {
              PYTHONUNBUFFERED: '0',
            },
            env: utils.pairList(self.envObj),
            args: [backend_service.metadata.name, std.toString(backend_service.spec.ports[0].port)],
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
    # .local is special in jsonnet so reference this entry with map key.
    spec+:{template+:{spec+:{containers:[super.containers[0]{image: params.images["local"]}]}}}
  },

}


