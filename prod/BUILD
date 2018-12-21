package(default_visibility = ["//visibility:public"])

load("@io_bazel_rules_jsonnet//jsonnet:jsonnet.bzl", "jsonnet_to_json")
jsonnet_to_json(
    name = "envs",
    src = "environments.jsonnet",
    outs = ["prod.json", "staging.json", "dev.json", "local.json"],
    multiple_outputs = 1,
    ext_code_files = ["@kube_jsonnet//:kube_lib"],
    ext_code_file_vars = ["kube"],
)

load("@k8s_object//:defaults.bzl", "k8s_object")

k8s_object(
  name = "prod",
  kind = "namespace",
  template = ":prod.json",
)
k8s_object(
  name = "staging",
  kind = "namespace",
  template = ":staging.json",
)
k8s_object(
  name = "dev",
  kind = "namespace",
  template = ":dev.json",
)
k8s_object(
  name = "local",
  kind = "namespace",
  template = ":local.json",
)

