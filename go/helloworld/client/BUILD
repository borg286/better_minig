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
    name = "client-image",
    srcs = ["main.go"],
    importpath = "github.com/bazelbuild/rules_k8s/rules_k8s/examples/hellogrpc/go/client",
    deps = [
        "//proto/helloworld:go",
    ] + GRPC_COMPILE_DEPS,
)
load("//rules:envs.bzl","PROD", "STAGING", "DEV", "LOCAL", "makeDeepShallowTargets")

image_base = "us.gcr.io/not-my-project/hello-grpc-go-client:"
images = {
    PROD: image_base + "my_prod_sha",
    STAGING: image_base + "my_staging_sha",
    DEV: image_base + "my_dev_sha",
    LOCAL: "us.gcr.io/my-developer-project/hello-grpc-go-client"
}


load("@io_bazel_rules_jsonnet//jsonnet:jsonnet.bzl", "jsonnet_to_json")
jsonnet_to_json(
    name = "kube-job",
    src = "job.jsonnet",
    outs = ["prod-job.json", "staging-job.json", "dev-job.json", "local-job.json"],
    multiple_outputs = 1,
    ext_code = {"images": "%s"%images},
    ext_code_files = ["@kube_jsonnet//:kube_lib", "//go/helloworld/server:service.json"],
    ext_code_file_vars = ["kube", "server"],
)

makeDeepShallowTargets(
    name_prefix = "job",
    image_url = images[LOCAL],
    image_target = ":client-image",
    deps_templates = ["//go/helloworld/server:server"],
    prod_json = ":prod-job.json",
    staging_json = ":staging-job.json",
    dev_json = ":dev-job.json",
    local_json = ":local-job.json",
    env_independent_jsons = {},
)

