package(default_visibility = ["//visibility:public"])

java_binary(
    name = "server-binary",
    main_class = "com.examples.grpc_redis.HelloServer",
    srcs = ["HelloServer.java"],
    deps = [
        "//proto/helloworld:java",
        "//proto/helloworld:java_compile_imports",
        "@org_pubref_rules_protobuf//java:netty_runtime_deps",
        "@org_redisson_redisson//jar",
    ],
    runtime_deps = ["//third_party/redisson:deps"],
)

load("@io_bazel_rules_docker//java:image.bzl", "java_image")
java_image(
    name = "server-image",
    main_class = "com.examples.grpc_redis.HelloServer",
    srcs = ["HelloServer.java"],
    deps = [
        "//proto/helloworld:java",
        "//proto/helloworld:java_compile_imports",
        "@org_pubref_rules_protobuf//java:netty_runtime_deps",
        "@org_redisson_redisson//jar",
    ],
    runtime_deps = ["//third_party/redisson:deps"],
)
NAME = "redis-grpc"
PORT = "50001"

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
    src = "server.jsonnet",
    outs = ["%s-server.json"%env, "%s-redis.json"%env, "%s-redis-svc.json"%env],
    multiple_outputs = 1,
    deps = ["@kube_jsonnet//:kube_lib", "//jsonnet:redis"],
    ext_code = {"params": "%s"%{"image": images[env], "port": PORT, "name": NAME, "env":env, "envs":ENVS}},
) for env in ENVS]

[jsonnet_to_json(
    name = "%s-service"%env,
    src = "//jsonnet:service.jsonnet",
    outs = ["%s-service.json"%env], 
    deps = ["@kube_jsonnet//:kube_lib"],
    ext_code = {"params": "%s"%{"name": NAME, "port": PORT, "env": env}},
) for env in ENVS]

load("@k8s_deploy//:defaults.bzl", "k8s_deploy")
load("@io_bazel_rules_k8s//k8s:objects.bzl", "k8s_objects")
load("@k8s_object//:defaults.bzl", "k8s_object")


[k8s_object(
  name = "%s_service"%env,
  kind = "service",
  template = ":%s-service.json"%env,
) for env in ENVS]

[k8s_object(
  name = "%s-deployment"%env,
  kind = "deployment",
  template = ":%s-server.json"%env,
) for env in [PROD, STAGING, DEV]]
k8s_object(
  name = "local-deployment",
  kind = "deployment",
  # Only tell k8s_deploy to look for and push the docker image for a local run
  images = {images[LOCAL]: ":server-image"},
  template = ":local-server.json",
)
[k8s_object(
  name = "%s-redis"%env,
  template = ":%s-redis.json"%env,
) for env in ENVS]
[k8s_object(
  name = "%s-redis-svc"%env,
  template = ":%s-redis-svc.json"%env,
) for env in ENVS]


# Shallow targets only spin up this service and deployment
[k8s_objects(
  name = "%s-shallow"%env,
  objects = [target%env for target in [":%s-deployment", ":%s_service", ":%s-redis", ":%s-redis-svc"]],
) for env in ENVS]


# Deep targets recursivly pull in all dependencies for sandbox/integration testing
# This server happens to not have any dependencies.
[k8s_objects(
  name = "%s-deep"%env,
  objects = [":%s-shallow"%env],
) for env in ENVS]
