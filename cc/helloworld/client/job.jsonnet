
local kube = std.extVar("kube");
local server = std.extVar("server");

{
  "job.json": std.prune(kube.Job("java-client") {
    spec+: {
    selector: null,
      template+: {
        spec+: {
          containers_+: {
            foo_cont: kube.Container("my-container") {
              image: "us.gcr.io/not-my-project/hello-grpc-cc-client:staging",
              command: ["java", "-jar", "client_deploy.jar", server.metadata.name + ":" + server.spec.ports[0].port],
            },
          },
        },
      },
    },
  }),
}
