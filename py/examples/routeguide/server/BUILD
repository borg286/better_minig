load("@io_bazel_rules_docker//python:image.bzl", "py_image")

py_image(
    name = "server-image",
    srcs = [
        "server.py",
    ],
    main = "server.py",
    data = ["//proto/examples/routeguide:routeguide_features"],
    deps = [
        "//py/examples/routeguide:resources",
        "//py/examples/routeguide:routeguide",
    ],
)

NAME = "py"

PORT = "50001"

# Each environment gets its own image tag. We use the LOCAL image and tell rules_k8s to swap in
# a locally built docker image, :server-image.
load("//prod:cluster_consts.bzl", "REGISTRY", "PROJECT", "MYNS", "ENVS")

image_base = "%s/%s/hello-grpc-%s:" % (REGISTRY, PROJECT, NAME)

LOCAL_IMAGE_NAME = image_base + "this_tag_will_be_replaced"

# Use jsonnet to produce json describing the main server deployment.
# Pass in the image, port, job name, environment (namespace). These params
# are refactored out so that we break a direct build link between compiling the server json
# from the kubernetes service that clients consume.
load("@io_bazel_rules_jsonnet//jsonnet:jsonnet.bzl", "jsonnet_to_json")

[jsonnet_to_json(
    name = "%s-json" % env,
    src = "server.jsonnet",
    outs = ["%s-server.json" % env],
    deps = [
        "@kube_jsonnet//:kube_lib",
        "//prod:envs",
        "//jsonnet:utils",
    ],
    # stringify a python map (with arbitrary nesting) then let jsonnet parse into json map.
    ext_code = {"params": "%s" % {
        "image_base": image_base,
        "local_image_name": LOCAL_IMAGE_NAME,
        "port": PORT,
        "name": NAME,
        "env": env,
    }},
) for env in ENVS]

[jsonnet_to_json(
    name = "%s-service" % env,
    src = "//jsonnet:service.jsonnet",
    outs = ["%s-service.json" % env],
    deps = [
        "@kube_jsonnet//:kube_lib",
        "//prod:envs",
    ],
    ext_code = {"params": "%s" % {
        "name": NAME,
        "port": PORT,
        "env": env,
    }},
    visibility = ["//visibility:public"],
) for env in ENVS]

load("@k8s_deploy//:defaults.bzl", "k8s_deploy")
load("@io_bazel_rules_k8s//k8s:objects.bzl", "k8s_objects")
load("@k8s_object//:defaults.bzl", "k8s_object")

[k8s_object(
    name = "%s_service" % env,
    kind = "service",
    template = ":%s-service.json" % env,
) for env in ENVS]

[k8s_deploy(
    name = "%s-deployment" % env,
    template = ":%s-server.json" % env,
    # In the case of a local deployment tell rules_k8s to
    # 1. Build the image, 2. push it, 3. get the SHA1 then 4. replace the
    # LOCAL_IMAGE_NAME used in the json's container with a reference to
    # the locally built one by its SHA.
    images = {LOCAL_IMAGE_NAME: ":server-image"} if (env == MYNS) else {},
) for env in ENVS]

# Shallow targets only spin up this service and deployment
[k8s_objects(
    name = "%s-shallow" % env,
    objects = [
        ":%s-deployment" % env,
        ":%s_service" % env,
    ],
) for env in ENVS]

# Deep targets recursivly pull in all dependencies for sandbox/integration testing
# This server happens to not have any dependencies.
[k8s_objects(
    name = "%s-deep" % env,
    objects = [":%s-shallow" % env],
    visibility = ["//visibility:public"],
) for env in ENVS]
