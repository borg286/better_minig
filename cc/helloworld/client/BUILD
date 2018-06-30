package(default_visibility = ["//visibility:public"])

licenses(["notice"])  # Apache 2.0

cc_library(
    name = "simple_lib",
    srcs = ["simple.cc"],
    hdrs = ["simple.h"],
    deps = ["//proto/helloworld:cc"],
)

load("@io_bazel_rules_docker//cc:image.bzl", "cc_image")
cc_image(
    name = "client",
    srcs = ["main.cc"],
    deps = [":simple_lib"],
)

image = "us.gcr.io/not-my-project/hello-grpc-cc-client:staging"

load("@io_bazel_rules_jsonnet//jsonnet:jsonnet.bzl", "jsonnet_to_json")
jsonnet_to_json(
    name = "kube-job",
    src = "job.jsonnet",
    outs = ["job.json"],
    multiple_outputs = 1,
    ext_code_files = ["@kube_jsonnet//:kube_lib", "//cc/helloworld/server:service_deployment.json"],
    ext_code_file_vars = ["kube", "server"],
)

load("@k8s_job//:defaults.bzl", "k8s_job")
k8s_job(
    name = "job",
    images = {
        image: ":client",
    },
    template = ":job.json",
)

