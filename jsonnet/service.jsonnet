
local kube = import 'external/kube_jsonnet/kube.libsonnet';
local params = std.extVar("params");

kube.Service(params.name) {
  spec: {
    selector: {"name": params.name},
    ports: [
      {
        port: std.parseInt(params.port),
        targetPort: std.parseInt(params.port),
      },
    ],
    type: "ClusterIP",
    clusterIP: null,
  },
}

