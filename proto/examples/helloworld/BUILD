load("@io_bazel_rules_go//go:def.bzl", "go_library")
load("@io_bazel_rules_go//proto:def.bzl", "go_proto_library")

package(default_visibility = ["//visibility:public"])

proto_library(
    name = "simple",
    srcs = [
        "simple.proto",
    ],
    visibility = [
        "//visibility:public",
    ],
)

proto_library(
    name = "proto_proto",
    srcs = ["simple.proto"],
)

go_proto_library(
    name = "proto_go_proto",
    compilers = ["@io_bazel_rules_go//proto:go_grpc"],
    importpath = "github.com/borg286/better_minig/proto/examples/helloworld",
    proto = ":proto_proto",
)

go_library(
    name = "go_default_library",
    embed = [":proto_go_proto"],
    importpath = "github.com/borg286/better_minig/proto/examples/helloworld",
)
