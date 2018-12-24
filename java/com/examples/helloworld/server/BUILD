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
NAME = "java"

load("//prod:cluster_consts.bzl", "REGISTRY", "PROJECT", "PROD", "STAGING", "DEV", "LOCAL")
image_base = "%s/%s/hello-grpc-%s:"%(REGISTRY, PROJECT, NAME)
images = {
    PROD: image_base + "my_prod_sha",
    STAGING: image_base + "my_staging_sha",
    DEV: image_base + "my_dev_sha",
    LOCAL: image_base + "local_tag"
}
PORT = "50001"

load("@io_bazel_rules_jsonnet//jsonnet:jsonnet.bzl", "jsonnet_to_json")
jsonnet_to_json(
    name = "json",
    src = "server.jsonnet",
    outs = ["prod-server.json", "staging-server.json", "dev-server.json", "local-server.json", "service.json"],
    multiple_outputs = 1,
    deps = ["@kube_jsonnet//:kube_lib"],          
    ext_code = {"params": "%s"%{"images": images, "port": PORT, "name": NAME}},
)


load("@k8s_deploy//:defaults.bzl", "k8s_deploy")
load("@io_bazel_rules_k8s//k8s:objects.bzl", "k8s_objects")
load("@k8s_object//:defaults.bzl", "k8s_object")


k8s_object(
  name = "prod_service",
  kind = "service",
  template = ":service.json",
  namespace = PROD,
)
k8s_object(
  name = "staging_service",
  kind = "service",
  template = ":service.json",
  namespace = STAGING,
)
k8s_object(
  name = "dev_service",
  kind = "service",
  template = ":service.json",
  namespace = DEV,
)
k8s_object(
  name = "local_service",
  kind = "service",
  template = ":service.json",
  namespace = LOCAL,
)

k8s_object(
  name = "prod-deployment",
  kind = "deployment",
  template = ":prod-server.json",
  namespace = PROD,
)
k8s_object(
  name = "staging-deployment",
  kind = "deployment",
  template = ":staging-server.json",
  namespace = STAGING,
)
k8s_object(
  name = "dev-deployment",
  kind = "deployment",
  template = ":dev-server.json",
  namespace = DEV,
)
k8s_object(
  name = "local-deployment",
  kind = "deployment",
  # Only tell k8s_deploy to look for and push the docker image for a local run
  images = {images[LOCAL]: ":server-image"},
  template = ":local-server.json",
  namespace = LOCAL,
)



# Shallow targets only spin up this service and deployment
k8s_objects(
  name = "prod-shallow",
  objects = [":prod-deployment", ":prod_service"],
)
k8s_objects(
  name = "staging-shallow",
  objects = [":staging-deployment", ":staging_service"],
)
k8s_objects(
  name = "dev-shallow",
  objects = [":dev-deployment", ":dev_service"],
)
k8s_objects(
  name = "local-shallow",
  objects = [":local-deployment", ":local_service"],
)



# Deep targets recursivly pull in all dependencies for sandbox/integration testing
# This server happens to not have any dependencies.
k8s_objects(
  name = "prod-deep",
  objects = [":prod-shallow", ":prod_service"],
)
k8s_objects(
  name = "staging-deep",
  objects = [":staging-deployment", ":staging_service"],
)
k8s_objects(
  name = "dev-deep",
  objects = [":dev-deployment", ":dev_service"],
)
k8s_objects(
  name = "local-deep",
  objects = [":local-deployment", ":local_service"],
)
