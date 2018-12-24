
local kube = import 'external/kube_jsonnet/kube.libsonnet';
local params = std.extVar("params");

kube.Service(params.name) {
  spec: {
    selector: {"name": params.name},
    ports: [
      {
        port: params.port,
        targetPort: params.port,
      },
    ],
    type: "ClusterIP",
  },
}

