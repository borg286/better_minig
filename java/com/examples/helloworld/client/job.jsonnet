
local kube = std.extVar("kube");
local server = std.extVar("server");

local image = "us.gcr.io/not-my-project/hello-grpc-java-client:staging"
{
  "job.json": std.prune(kube.Job("java-client") {
    spec+: {
    selector: null,
      template+: {
        spec+: {
          containers_+: {
            foo_cont: kube.Container("client") {
              image: image,
              command: ["java", "-jar", "client_deploy.jar", server.metadata.name + ":" + server.spec.ports[0].port],
            },
          },
        },
      },
    },
  }),
}
