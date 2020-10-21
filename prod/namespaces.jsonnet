local kube = import "external/kube_jsonnet/kube.libsonnet";
local user = std.extVar("user");
{
  "prod.json": kube.Namespace("prod"),
  "staging.json": kube.Namespace("staging"),
  "dev.json": kube.Namespace("dev"),
  "myns.json": kube.Namespace(user),
}
