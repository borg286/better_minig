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

go_proto_library(
    name = "routeguide_go_proto",
    compilers = ["@io_bazel_rules_go//proto:go_grpc"],
    importpath = "github.com/borg286/better_minig/proto/examples/routeguide",
    proto = ":routeguide_proto",
    visibility = ["//visibility:public"],
)

go_library(
    name = "go_default_library",
    embed = [":routeguide_go_proto"],
    importpath = "github.com/borg286/better_minig/proto/examples/routeguide",
    visibility = ["//visibility:public"],
)
