local kube = import "external/kube_jsonnet/kube.libsonnet";

{
  "prod.json": kube.Namespace("prod"),
  "staging.json": kube.Namespace("staging"),
  "dev.json": kube.Namespace("dev"),
  "local.json": kube.Namespace("local"),
}
