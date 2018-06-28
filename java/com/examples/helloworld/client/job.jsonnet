
local kube = std.extVar("kube");

{
  "job.json": std.prune(kube.Job("java-client") {
    spec+: {
    selector: null,
      template+: {
        spec+: {
          containers_+: {
            foo_cont: kube.Container("my-container") {
              image: "us.gcr.io/not-my-project/hello-grpc-client:staging",
              command: ["java", "-jar", "client_deploy.jar", "35.225.169.98"],
            },
          },
        },
      },
    },
  }),
}
