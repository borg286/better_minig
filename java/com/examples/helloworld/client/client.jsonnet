
local kube = import 'external/kube_jsonnet/kube.libsonnet';
local backend_service = std.extVar("backend_service");
local params = std.extVar("params");

local template = std.prune(kube.Deployment(params["name"]) {
  spec+: {
    template+: {
      spec+: {
        containers_+: {
          foo_cont: kube.Container("client") {
            image: "will be replaced",
            args: [backend_service.metadata.name,  std.toString(backend_service.spec.ports[0].port)],
          },
        },
      },
    },
  },
});


{
  "prod-job.json": template {
    spec+:{template+:{spec+:{containers:[super.containers[0]{image: params.images.prod}]}}}
  },
  "staging-job.json": template {
    spec+:{template+:{spec+:{containers:[super.containers[0]{image: params.images.staging}]}}}
  },
  "dev-job.json": template {
    spec+:{template+:{spec+:{containers:[super.containers[0]{image: params.images.dev}]}}}
  },
  "local-job.json": template {
    spec+:{template+:{spec+:{containers:[super.containers[0]{image: params.images.local}]}}}
  },

}
