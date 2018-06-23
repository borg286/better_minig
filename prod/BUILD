# General build targets available for consumption in any service

package(default_visibility = ["//visibility:public"])

load("@io_bazel_rules_jsonnet//jsonnet:jsonnet.bzl", "jsonnet_library")

jsonnet_library(
    name = "deploy_lib",
    srcs = ["deployment.libsonnet"],
)

jsonnet_library(
    name = "container_lib",
    srcs = ["container.libsonnet"],
)

