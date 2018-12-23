local kube = import 'external/kube_jsonnet/kube.libsonnet';
local utils = import 'jsonnet/utils.libsonnet';
local server = std.extVar("server");
local images = std.extVar("images");


local template = std.prune(kube.Deployment("py-client") {
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
            args: [server.metadata.name, std.toString(server.spec.ports[0].port)],
          },
        },
      },
    },
  },
});


{
  "prod-job.json": template {
    spec+:{template+:{spec+:{containers:[super.containers[0]{image: images["prod"]}]}}}
  },
  "staging-job.json": template {
    spec+:{template+:{spec+:{containers:[super.containers[0]{image: images["staging"]}]}}}
  },
  "dev-job.json": template {
    spec+:{template+:{spec+:{containers:[super.containers[0]{image: images["dev"]}]}}}
  },
  "local-job.json": template {
    spec+:{template+:{spec+:{containers:[super.containers[0]{image: images["local"]}]}}}
  },

}


