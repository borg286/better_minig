package(default_visibility = ["//visibility:public"])

load("@io_bazel_rules_docker//go:image.bzl", "go_image")
load("@org_pubref_rules_protobuf//go:rules.bzl", "GRPC_COMPILE_DEPS")

go_image(
    name = "server-image",
    srcs = ["main.go"],
    importpath = "github.com/bazelbuild/not-my-project/go/helloworld/server",
    deps = [
        "//proto/helloworld:go",
    ] + GRPC_COMPILE_DEPS,
)

image = "us.gcr.io/not-my-project/hello-grpc-go:staging"
port = "50001"

load("@io_bazel_rules_jsonnet//jsonnet:jsonnet.bzl", "jsonnet_to_json")
jsonnet_to_json(
    name = "kube-service",
    src = "server.jsonnet",
    outs = ["server.json", "service.json"],
    multiple_outputs = 1,
    ext_code_files = ["@kube_jsonnet//:kube_lib"],
    ext_code_file_vars = ["kube"],
)

load("@k8s_deploy//:defaults.bzl", "k8s_deploy")
load("@k8s_service//:defaults.bzl", "k8s_service")
load("@io_bazel_rules_k8s//k8s:objects.bzl", "k8s_objects")

k8s_deploy(
    name = "deployment",
    images = {
        image: ":server-image",
    },
    template = ":frontend.json",
)

k8s_service(
    name = "service",
    template = ":service.json",
)

k8s_objects(
    name = "deployment_service",
    objects = [
        ":deployment",
        ":service",
    ],
)

