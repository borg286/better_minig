
local kube = std.extVar("kube");
local server = std.extVar("server");
local images = std.extVar("images");

local template = std.prune(kube.Job("cc-client") {
  spec+: {
  selector: null,
    template+: {
      spec+: {
        containers_+: {
          foo_cont: kube.Container("client") {
            image: "will be replaced",
            command: ["client", server.metadata.name + ":" + server.spec.ports[0].port],
          },
        },
      },
    },
  },
});


{
  "prod-job.json": template {
    spec+: {
      template+: {
        spec+: {
          containers_+: {
            foo_cont+: {
              image: images["prod"],
  }}}}}},
  "staging-job.json": template {                    
    spec+: {
      template+: {
        spec+: {
          containers_+: {
            foo_cont+: {
              image: images["staging"],
  }}}}}},
  "dev-job.json": template {                    
    spec+: {
      template+: {
        spec+: {
          containers_+: {
            foo_cont+:{
              image: images["dev"],
  }}}}}},
  "local-job.json": template {                    
    spec+: {
      template+: {
        spec+: {
          containers_+: {
            foo_cont+: {
              image: images["local"],
  }}}}}},
}
