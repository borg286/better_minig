
local kube = std.extVar("kube");
local server = std.extVar("server");
local images = std.extVar("images");

local template = std.prune(kube.Deployment("cc-client") {
  spec+: {
    template+: {
      spec+: {
        containers_+: {
          foo_cont: kube.Container("client") {
            image: "will be replaced",
            args: [server.metadata.name + ":" + server.spec.ports[0].port],
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
