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

# LOCAL image and tell rules_k8s to swap in
# a locally built docker image, :server-image.
load("//prod:cluster_consts.bzl", "REGISTRY", "PROJECT")

image_base = "%s/%s/hello-routeguide-%s:" % (REGISTRY, PROJECT, NAME)

IMAGE_NAME = image_base + "this_tag_will_be_replaced"

# Use jsonnet to produce json describing the main server deployment.
# Pass in the image, port, job name, environment (namespace). These params
# are refactored out so that we break a direct build link between compiling the server json
# from the kubernetes service that clients consume.
load("@io_bazel_rules_jsonnet//jsonnet:jsonnet.bzl", "jsonnet_to_json")

jsonnet_to_json(
    name = "json",
    src = "server.jsonnet",
    outs = ["server.json"],
    multiple_outputs = True,
    deps = [
        "@kube_jsonnet//:kube_lib",
        "//prod:envs",
        "//jsonnet:utils",
    ],
    # stringify a python map (with arbitrary nesting) then let jsonnet parse into json map.
    ext_code = {"params": "%s" % {
        "image_name": IMAGE_NAME,
        "port": PORT,
        "name": NAME,
    }},
)


jsonnet_to_json(
    name = "service_json",
    src = "//jsonnet:service.jsonnet",
    outs = ["service.json"],
    deps = [
        "@kube_jsonnet//:kube_lib",
    ],
    ext_code = {"params": "%s" % {
        "name": NAME,
        "port": PORT,
    }},
    visibility = ["//visibility:public"],
)

load("@k8s_deploy//:defaults.bzl", "k8s_deploy")
load("@io_bazel_rules_k8s//k8s:objects.bzl", "k8s_objects")
load("@k8s_object//:defaults.bzl", "k8s_object")

k8s_object(
    name = "service",
    kind = "service",
    template = ":service.json",
)

k8s_deploy(
    name = "deployment",
    template = ":server.json",
    # Tell rules_k8s to
    # 1. Build the image, 2. push it, 3. get the SHA1 then 4. replace the
    # IMAGE_NAME used in the json's container with a reference to
    # the locally built one by its SHA.
    images = {IMAGE_NAME: ":server-image"},
)

# Shallow targets only spin up this service and deployment
k8s_objects(
    name = "shallow",
    objects = [
      ":deployment",
      ":service",
    ],
)

# Deep targets recursivly pull in all dependencies for sandbox/integration testing
# This server happens to not have any dependencies.
k8s_objects(
    name = "deep",
    objects = [
      ":shallow",
    ],
    visibility = ["//visibility:public"],
)
