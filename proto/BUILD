load("@io_bazel_rules_go//proto:def.bzl", "go_proto_library")
load("@rules_proto_grpc//java:defs.bzl", "java_grpc_library")


proto_library(
    name = "health_proto",
    srcs = [
        "health.proto",
    ],
    visibility = ["//visibility:public"],
)
java_grpc_library(
    name = "health-java",
    deps = ["health_proto"],
    visibility = ["//visibility:public"],
)
