local kube = import "external/kube_jsonnet/kube.libsonnet";
local params = std.extVar("params");
{
  "prod.json": kube.Namespace(params.envs.PROD),
  "staging.json": kube.Namespace(params.envs.STAGING),
  "dev.json": kube.Namespace(params.envs.DEV),
  "local.json": kube.Namespace(params.envs.LOCAL),
}
