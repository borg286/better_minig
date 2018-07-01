package(default_visibility = ["//visibility:public"])

load("@io_bazel_rules_docker//python:image.bzl", "py_image")
load("@py_pip//:requirements.bzl", "requirement")

py_image(
    name = "client-image",
    srcs = ["client.py"],
    deps = [
        requirement("grpcio"),
        "//examples/hellogrpc/proto:py",
    ],
    main = "client.py",
)

image = "us.gcr.io/not-my-project/hello-grpc-py-client:staging"

load("@io_bazel_rules_jsonnet//jsonnet:jsonnet.bzl", "jsonnet_to_json")
jsonnet_to_json(
    name = "kube-job",
    src = "job.jsonnet",
    outs = ["job.json"],
    multiple_outputs = 1,
    ext_code_files = ["@kube_jsonnet//:kube_lib", "//py/examples/hellogrpc/server:service.json"],
    ext_code_file_vars = ["kube", "server"],
)

load("@k8s_job//:defaults.bzl", "k8s_job")
k8s_job(
    name = "job",
    images = {
        image: ":client-image",
    },
    template = ":job.json",
)

