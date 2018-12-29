package(default_visibility = ["//visibility:public"])

load("@io_bazel_rules_jsonnet//jsonnet:jsonnet.bzl", "jsonnet_to_json", "jsonnet_library")
load("//prod:cluster_consts.bzl", "PROD", "STAGING", "DEV", "MYNS", "ENVS")
jsonnet_to_json(
  name = "namespaces",
  src = "namespaces.jsonnet",
  outs = ["%s.json"%env for env in ENVS],
  multiple_outputs = 1,
  deps = ["@kube_jsonnet//:kube_lib", ":envs"],
  ext_code = {"params": "%s"%{"envs": ENVS, "BUILD_USER": "{BUILD_USER}"}},
)

load("@k8s_object//:defaults.bzl", "k8s_object")

[k8s_object(
  name = "%s"%env,
  kind = "namespace",
  template = ":%s.json"%env,
) for env in ENVS]

_BUILD_USER = "{BUILD_USER}"
jsonnet_to_json(
  name = "environment_names",
  src = "dummy.jsonnet",
  outs = ["environment_names.json"],
  ext_code = {"ret":"%s"%{"prod":PROD, "staging": STAGING, "dev": DEV, "myns": _BUILD_USER}},
)
jsonnet_library(
  name = "envs",
  srcs = ["envs.libsonnet"],
  data = ["environment_names.json"],
)
