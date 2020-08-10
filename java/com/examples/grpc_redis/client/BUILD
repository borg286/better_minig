load("@io_bazel_rules_docker//java:image.bzl", "java_image")




java_binary(
    name = "client-binary",
    srcs = [
        "RouteGuideClient.java",
    ],
    main_class = "io.grpc.examples.grpc_redis.RouteGuideClient",
    resources = ["//java/com/examples/routeguide:route_guide_db.json"],
    deps = [
        "//java/com/examples/grpc_redis:routeguide",
        "//java/com/examples/grpc_redis:util",
        "@maven//:org_redisson_redisson_all",
    ],
    runtime_deps = [
        "@io_netty_netty_common//jar",
        "@io_netty_netty_tcnative_boringssl_static//jar",
    ],
)


java_image(
    name = "client-image",
    srcs = [
        "RouteGuideClient.java",
    ],
    main_class = "io.grpc.examples.grpc_redis.RouteGuideClient",
    resources = ["//java/com/examples/routeguide:route_guide_db.json"],
    deps = [
        "//java/com/examples/grpc_redis:routeguide",
        "//java/com/examples/grpc_redis:util",
        "@maven//:org_redisson_redisson_all",
    ],
    runtime_deps = [
        "@io_netty_netty_common//jar",
        "@io_netty_netty_tcnative_boringssl_static//jar",
    ],
)

NAME = "java-client"

BACKEND = "//java/com/examples/grpc_redis/server"

load("//prod:cluster_consts.bzl", "REGISTRY", "PROJECT", "MYNS", "ENVS")

image_base = "%s/%s/hello-grpc-%s:" % (REGISTRY, PROJECT, NAME)

LOCAL_IMAGE_NAME = image_base + "this_tag_will_be_replaced"

load("@io_bazel_rules_jsonnet//jsonnet:jsonnet.bzl", "jsonnet_to_json")

[jsonnet_to_json(
    name = "%s-json" % env,
    src = "client.jsonnet",
    outs = ["%s-client.json" % env],
    deps = [
        "@kube_jsonnet//:kube_lib",
        "//prod:envs",
    ],
    # json files are flat so we only need a variable to point to its contents.
    ext_code_file_vars = ["backend_service", "redis_service"],
    ext_code_files = [BACKEND + ":%s-service.json" % env, "//prod/redis:grpc-redis-%s-svc.json" % env],
    ext_code = {"params": "%s" % {
        "image_base": image_base,
        "local_image_name": LOCAL_IMAGE_NAME,
        "name": NAME,
        "env": env,
    }},
) for env in ENVS]

load("@k8s_deploy//:defaults.bzl", "k8s_deploy")
load("@io_bazel_rules_k8s//k8s:objects.bzl", "k8s_objects")
load("@k8s_object//:defaults.bzl", "k8s_object")

[k8s_deploy(
    name = "%s-client" % env,
    template = ":%s-client.json" % env,
    # In the case of a local deployment tell rules_k8s to
    # 1. Build the image, 2. push it, 3. get the SHA1 then 4. replace the
    # LOCAL_IMAGE_NAME used in the json's container with a reference to
    # the locally built one by its SHA.
    images = {LOCAL_IMAGE_NAME: ":client-image"} if (env == MYNS) else {},
) for env in ENVS]

# Shallow targets only spin up this service and deployment
[k8s_objects(
    name = "%s-shallow" % env,
    objects = [":%s-client" % env],
) for env in ENVS]

# Deep targets recursivly pull in all dependencies for sandbox/integration testing
[k8s_objects(
    name = "%s-deep" % env,
    objects = [
        ":%s-client" % env,
        BACKEND + ":%s-deep" % env,
    ],
    visibility = ["//visibility:public"],
) for env in ENVS]
