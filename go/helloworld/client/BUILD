package(default_visibility = ["//visibility:public"])

load("@io_bazel_rules_go//go:def.bzl", "go_binary")
load("@io_bazel_rules_docker//go:image.bzl", "go_image")
load("@org_pubref_rules_protobuf//go:rules.bzl", "GRPC_COMPILE_DEPS")

go_binary(
    name = "client-binary",
    srcs = ["main.go"],
    importpath = "github.com/bazelbuild/rules_k8s/rules_k8s/examples/hellogrpc/go/client",
    deps = [
        "//proto/helloworld:go",
    ] + GRPC_COMPILE_DEPS,
)

go_image(
    name = "client",
    srcs = ["main.go"],
    importpath = "github.com/bazelbuild/rules_k8s/rules_k8s/examples/hellogrpc/go/client",
    deps = [
        "//proto/helloworld:go",
    ] + GRPC_COMPILE_DEPS,
)
image = "us.gcr.io/not-my-project/hello-grpc-go-client:staging"

load("@io_bazel_rules_jsonnet//jsonnet:jsonnet.bzl", "jsonnet_to_json")
jsonnet_to_json(
    name = "kube-job",
    src = "job.jsonnet",
    outs = ["job.json"],
    multiple_outputs = 1,
    ext_code_files = ["@kube_jsonnet//:kube_lib", "//go/helloworld/server:service_deployment.json"],
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

