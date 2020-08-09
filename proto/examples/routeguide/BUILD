load("@io_bazel_rules_go//go:def.bzl", "go_library")
load("@io_bazel_rules_go//proto:def.bzl", "go_proto_library")

proto_library(
    name = "routeguide_proto",
    srcs = [
        "routeguide.proto",
    ],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "routeguide_features",
    srcs = [
        "routeguide_features.json",
    ],
    visibility = ["//visibility:public"],
)
