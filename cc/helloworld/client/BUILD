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

PROD = "prod"
STAGING = "staging"
DEV = "dev"
LOCAL = "local"

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


load("@k8s_deploy//:defaults.bzl", "k8s_deploy")
load("@io_bazel_rules_k8s//k8s:objects.bzl", "k8s_objects")
load("@k8s_object//:defaults.bzl", "k8s_object")


k8s_object(
  name = "prod-job",
  kind = "job",
  template = ":prod-job.json"
)
k8s_object(
  name = "staging-job",
  kind = "job",
  template = ":staging-job.json"
)
k8s_object(
  name = "dev-job",
  kind = "job",
  template = ":dev-job.json"
)
k8s_object(
  name = "local-job",
  kind = "job",
  # Only tell k8s_deploy to look for and push the docker image for a local run
  images = {images[LOCAL]: ":client-image"},
  template = ":local-job.json"
)


# Shallow targets only spin up this service and deployment
k8s_objects(
  name = "prod-shallow",
  objects = [":prod-job"],
)
k8s_objects(
  name = "staging-shallow",
  objects = [":staging-job"],
)
k8s_objects(
  name = "dev-shallow",
  objects = [":dev-job"],
)
k8s_objects(
  name = "local-shallow",
  objects = [":local-job"],
)



# Deep targets recursivly pull in all dependencies for sandbox/integration testing
k8s_objects(
  name = "prod-deep",
  objects = [":prod-job", "//java/com/examples/helloworld/server:prod-deep"],
)
k8s_objects(
  name = "staging-deep",
  objects = [":staging-job", "//java/com/examples/helloworld/server:staging-deep"],
)
k8s_objects(
  name = "dev-deep",
  objects = [":dev-job", "//java/com/examples/helloworld/server:dev-deep"],
)
k8s_objects(
  name = "local-deep",
  objects = [":local-job", "//java/com/examples/helloworld/server:local-deep"],
)





