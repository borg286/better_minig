package(default_visibility = ["//visibility:public"])

licenses(["notice"])  # Apache 2.0

cc_library(
    name = "simple_lib",
    srcs = ["simple.cc"],
    hdrs = ["simple.h"],
    deps = ["//proto/helloworld:cc"],
)

cc_binary(
    name = "client-binary",
    srcs = ["main.cc"],
    deps = [":simple_lib"],
)

load("@io_bazel_rules_docker//cc:image.bzl", "cc_image")
cc_image(
    name = "client-image",
    binary = ":client-binary",
)

load("//rules:envs.bzl","PROD", "STAGING", "DEV", "LOCAL", "makeDeepShallowTargets")

image_base = "us.gcr.io/not-my-project/hello-grpc-cc-client:"
images = {
    PROD: image_base + "my_prod_sha",
    STAGING: image_base + "my_staging_sha",
    DEV: image_base + "my_dev_sha",
    LOCAL: "us.gcr.io/my-developer-project/hello-grpc-cc-client"
}


load("@io_bazel_rules_jsonnet//jsonnet:jsonnet.bzl", "jsonnet_to_json")
jsonnet_to_json(
    name = "kube-job",
    src = "job.jsonnet",
    outs = ["prod-job.json", "staging-job.json", "dev-job.json", "local-job.json"],
    multiple_outputs = 1,
    ext_code = {"images": "%s"%images},
    ext_code_files = ["@kube_jsonnet//:kube_lib", "//cc/helloworld/server:service.json"],
    ext_code_file_vars = ["kube", "server"],
)

makeDeepShallowTargets(
    image_url = images[LOCAL],
    image_target = ":client-image",
    deps_templates = ["//cc/helloworld/server"],
    prod_json = ":prod-job.json",
    staging_json = ":staging-job.json",
    dev_json = ":dev-job.json",
    local_json = ":local-job.json",
    env_independent_jsons = {},
)

