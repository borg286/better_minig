package(default_visibility = ["//visibility:public"])

java_binary(
    name = "server-binary",
    main_class = "com.examples.helloworld.server.HelloServer",
    srcs = ["HelloServer.java"],
    deps = [
        "//proto/helloworld:java",
        "//proto/helloworld:java_compile_imports",
        "@org_pubref_rules_protobuf//java:netty_runtime_deps",
    ],
)

load("@io_bazel_rules_docker//java:image.bzl", "java_image")
java_image(
    name = "server-image",
    main_class = "com.examples.helloworld.server.HelloServer",
    srcs = ["HelloServer.java"],
    deps = [
        "//proto/helloworld:java",
        "//proto/helloworld:java_compile_imports",
        "@org_pubref_rules_protobuf//java:netty_runtime_deps",
    ],
)

PROD = "prod"
STAGING = "staging"
DEV = "dev"
LOCAL = "local"
# Both the kubernetes json as well as the k8s_deploy need to know the image.
# This section fixes the docker image tags for each environment as the soure of truth.
# The k8s_deploy only needs it so that it can know where to push the -image target above.
# It is preferred to put as much as possible in the .jsonnet as possible. Only put here
# what needs to get shared between targets as strings. 
image_base = "gcr.io/fiery-orb-681/hello-grpc-java-server:"
images = {
    PROD: image_base + "my_prod_sha",
    STAGING: image_base + "my_staging_sha",
    DEV: image_base + "my_dev_sha",
    LOCAL: "localhost:32000/fiery-orb-681/hello-grpc-java-server:random-tag"
}
PORT = "50001"

load("@io_bazel_rules_jsonnet//jsonnet:jsonnet.bzl", "jsonnet_to_json")
jsonnet_to_json(
    name = "json",
    src = "server.jsonnet",
    outs = ["prod-server.json", "staging-server.json", "dev-server.json", "local-server.json", "service.json"],
    multiple_outputs = 1,
    ext_code = {"images": "%s"%images, "port": PORT},
    ext_code_files = ["@kube_jsonnet//:kube_lib"],
    ext_code_file_vars = ["kube"],
)


load("@k8s_deploy//:defaults.bzl", "k8s_deploy")
load("@io_bazel_rules_k8s//k8s:objects.bzl", "k8s_objects")
load("@k8s_object//:defaults.bzl", "k8s_object")


k8s_object(
  name = "service",
  kind = "service",
  template = ":service.json",
)

k8s_object(
  name = "prod-deployment",
  kind = "deployment",
  template = ":prod-server.json"
)
k8s_object(
  name = "staging-deployment",
  kind = "deployment",
  template = ":staging-server.json"
)
k8s_object(
  name = "dev-deployment",
  kind = "deployment",
  template = ":dev-server.json"
)
k8s_object(
  name = "local-deployment",
  kind = "deployment",
  # Only tell k8s_deploy to look for and push the docker image for a local run
  images = {images[LOCAL]: ":server-image"},
  template = ":local-server.json"
)



# Shallow targets only spin up this service and deployment
k8s_objects(
  name = "prod-shallow",
  objects = [":prod-deployment", ":service"],
)
k8s_objects(
  name = "staging-shallow",
  objects = [":staging-deployment", ":service"],
)
k8s_objects(
  name = "dev-shallow",
  objects = [":dev-deployment", ":service"],
)
k8s_objects(
  name = "local-shallow",
  objects = [":local-deployment", ":service"],
)



# Deep targets recursivly pull in all dependencies for sandbox/integration testing
# This server happens to not have any dependencies.
k8s_objects(
  name = "prod-deep",
  objects = [":prod-deployment", ":service"],
)
k8s_objects(
  name = "staging-deep",
  objects = [":staging-deployment", ":service"],
)
k8s_objects(
  name = "dev-deep",
  objects = [":dev-deployment", ":service"],
)
k8s_objects(
  name = "local-deep",
  objects = [":local-deployment", ":service"],
)

  
