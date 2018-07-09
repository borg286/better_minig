
local kube = std.extVar("kube");
local server = std.extVar("server");
local images = std.extVar("images");

local template = std.prune(kube.Job("java-client") {
  spec+: {
  selector: null,
    template+: {
      spec+: {
        containers_+: {
          foo_cont: kube.Container("client") {
            image: "will be replaced",
//              command: ["java", "-version"],
            args: [server.metadata.name,  std.toString(server.spec.ports[0].port)],
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
