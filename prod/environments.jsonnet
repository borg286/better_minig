local kube = std.extVar("kube");

{
  "prod.json": kube.Namespace("prod"),
  "staging.json": kube.Namespace("staging"),
  "dev.json": kube.Namespace("dev"),
  "local.json": kube.Namespace("local"),
}
