package(default_visibility = ["//visibility:public"])

load("@io_bazel_rules_docker//java:image.bzl", "java_image")
java_image(
    name = "client-image",
    main_class = "com.examples.helloworld.client.HelloClient",
    srcs = ["HelloClient.java"],
    deps = [
        "//proto/helloworld:java",
        "//proto/helloworld:java_compile_imports",
        "@org_pubref_rules_protobuf//java:netty_runtime_deps",
    ],
)
NAME = "java-client"
BACKEND = "//java/com/examples/helloworld/server"



load("//prod:cluster_consts.bzl", "REGISTRY", "PROJECT", "PROD", "STAGING", "DEV", "LOCAL", "ENVS")
image_base = "%s/%s/hello-grpc-%s:"%(REGISTRY, PROJECT, NAME)

images = {
    PROD: image_base + "my_prod_sha",
    STAGING: image_base + "my_staging_sha",
    DEV: image_base + "my_dev_sha",
    LOCAL: image_base + "local_tag"
}

load("@io_bazel_rules_jsonnet//jsonnet:jsonnet.bzl", "jsonnet_to_json")
[jsonnet_to_json(
    name = "%s-json"%env,
    src = "client.jsonnet",
    outs = ["%s-client.json"%env],
    ext_code = {"params": "%s"%{"image":images[env], "name": NAME}},
    # deps may depend on other jsonnet_library targets so pull in their deps too.
    deps = ["@kube_jsonnet//:kube_lib"],
    # json files are flat so we only need a variable to point to its contents.
    ext_code_file_vars = ["backend_service"],
    ext_code_files = [BACKEND + ":%s-service.json"%env],
) for env in ENVS]

load("@k8s_deploy//:defaults.bzl", "k8s_deploy")
load("@io_bazel_rules_k8s//k8s:objects.bzl", "k8s_objects")
load("@k8s_object//:defaults.bzl", "k8s_object")


[k8s_object(
  name = "%s-client"%env,
  kind = "deployment",
  template = ":%s-client.json"%env,
  namespace = PROD,
) for env in [PROD, STAGING, DEV]]
k8s_object(
  name = "local-client",
  kind = "deployment",
  # Only tell k8s_deploy to look for and push the docker image for a local run
  images = {images[LOCAL]: ":client-image"},
  template = ":local-client.json",
  namespace = LOCAL,
)


# Shallow targets only spin up this service and deployment
[k8s_objects(
  name = "%s-shallow"%env,
  objects = [":%s-client"%env],
) for env in ENVS]


# Deep targets recursivly pull in all dependencies for sandbox/integration testing
[k8s_objects(
  name = "%s-deep"%env,
  objects = [":%s-client"%env, BACKEND + ":%s-deep"%env],
) for env in ENVS]





