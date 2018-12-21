
local kube = std.extVar("kube");
local port = std.extVar("port");
local name = std.extVar("name");


{
  "service.json": kube.Service(name) {
    spec: {
      selector: {"name": name},
      ports: [{
          port: port,
          targetPort: port
        }
      ],
      type: "ClusterIP"
  }
}
