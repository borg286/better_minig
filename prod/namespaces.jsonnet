local kube = import "external/kube_jsonnet/kube.libsonnet";
local user = std.extVar("user");
local envs = import "prod/envs.libsonnet";
{
  "prod.json": kube.Namespace(envs.prod.name),
  "staging.json": kube.Namespace(envs.staging.name),
  "dev.json": kube.Namespace(envs.dev.name),
  "myns.json": kube.Namespace(user),
}
