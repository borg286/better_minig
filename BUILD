load("@io_bazel_rules_go//go:def.bzl", "go_library")
load("@io_bazel_rules_go//proto:def.bzl", "go_proto_library")
load("@bazel_gazelle//:def.bzl", "gazelle")

# gazelle:prefix github.com/borg286/better_minig
gazelle(name = "gazelle")

proto_library(
    name = "greeter_proto",
    srcs = ["my.proto"],
    visibility = ["//visibility:public"],
)

go_proto_library(
    name = "greeter_go_proto",
    compilers = ["@io_bazel_rules_go//proto:go_grpc"],
    importpath = "github.com/borg286/better_minig",
    proto = ":greeter_proto",
    visibility = ["//visibility:public"],
)

go_library(
    name = "go_default_library",
    embed = [":greeter_go_proto"],
    importpath = "github.com/borg286/better_minig",
    visibility = ["//visibility:public"],
)
