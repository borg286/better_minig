local kube = import "external/kube_jsonnet/kube.libsonnet";

local registry_depl = kube.Deployment("registry") {
    spec+: {
      template+: {
        spec+: {
          containers_+: {
            redis_master: kube.Container("registry") {
              image: "registry:2",
              ports_+: {
                main: { containerPort: 5000 },
  }}}}}}};


local registry_svc = kube.Service("registry") {
    spec:{
      selector: {"name": "registry"},
      ports: [{port:31000, targetPort: 5000, nodePort:31000}],
      type: "NodePort",
    }
  };

{
"registry-depl.json": registry_depl,
"registry-svc.json": registry_svc,
}
