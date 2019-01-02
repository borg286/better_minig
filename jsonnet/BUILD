package(default_visibility = ["//visibility:public"])

load("@io_bazel_rules_jsonnet//jsonnet:jsonnet.bzl", "jsonnet_library")

jsonnet_library(
    name = "utils",
    srcs = ["utils.libsonnet"],
)

jsonnet_library(
    name = "redis",
    srcs = ["redis.libsonnet"],
    deps = ["@kube_jsonnet//:kube_lib"],
)

exports_files(
    srcs = [
        "utils.libsonnet",
        "redis.libsonnet",
        "service.jsonnet",
    ],
)
