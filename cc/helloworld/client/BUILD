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
NAME = "grpc-cc-client"
BACKEND = "//cc/helloworld/server"

load("//prod:cluster_consts.bzl", "REGISTRY", "PROJECT", "PROD", "STAGING", "DEV", "LOCAL")
image_base = "%s/%s/hello-grpc-%s:"%(REGISTRY, PROJECT, NAME)

images = {
    PROD: image_base + "my_prod_sha",
    STAGING: image_base + "my_staging_sha",
    DEV: image_base + "my_dev_sha",
    LOCAL: image_base + "local_tag"
}

load("@io_bazel_rules_jsonnet//jsonnet:jsonnet.bzl", "jsonnet_to_json")
jsonnet_to_json(
    name = "json",
    src = "client.jsonnet",
    outs = ["prod-client.json", "staging-client.json", "dev-client.json", "local-client.json"],
    multiple_outputs = 1,
    ext_code = {"params": "%s"%{"images":images, "name": NAME}},
    # deps may depend on other jsonnet_library targets so pull in their deps too.
    deps = ["@kube_jsonnet//:kube_lib"],
    # json files are flat so we only need a variable to point to its contents.
    ext_code_file_vars = ["backend_service"],
    ext_code_files = [BACKEND + ":service.json"],
)

load("@k8s_deploy//:defaults.bzl", "k8s_deploy")
load("@io_bazel_rules_k8s//k8s:objects.bzl", "k8s_objects")
load("@k8s_object//:defaults.bzl", "k8s_object")


k8s_object(
  name = "prod-client",
  kind = "deployment",
  template = ":prod-client.json",
  namespace = PROD,
)
k8s_object(
  name = "staging-client",
  kind = "deployment",
  template = ":staging-client.json",
  namespace = STAGING,
)
k8s_object(
  name = "dev-client",
  kind = "deployment",
  template = ":dev-client.json",
  namespace = DEV,
)
k8s_object(
  name = "local-client",
  kind = "deployment",
  # Only tell k8s_deploy to look for and push the docker image for a local run
  images = {images[LOCAL]: ":client-image"},
  template = ":local-client.json",
  namespace = LOCAL,
)


# Shallow targets only spin up this service and deployment
k8s_objects(
  name = "prod-shallow",
  objects = [":prod-client"],
)
k8s_objects(
  name = "staging-shallow",
  objects = [":staging-client"],
)
k8s_objects(
  name = "dev-shallow",
  objects = [":dev-client"],
)
k8s_objects(
  name = "local-shallow",
  objects = [":local-client"],
)



# Deep targets recursivly pull in all dependencies for sandbox/integration testing
k8s_objects(
  name = "prod-deep",
  objects = [":prod-client", BACKEND + ":prod-deep"],
)
k8s_objects(
  name = "staging-deep",
  objects = [":staging-client", BACKEND + ":staging-deep"],
)
k8s_objects(
  name = "dev-deep",
  objects = [":dev-client", BACKEND + ":dev-deep"],
)
k8s_objects(
  name = "local-deep",
  objects = [":local-client", BACKEND + ":local-deep"],
)





