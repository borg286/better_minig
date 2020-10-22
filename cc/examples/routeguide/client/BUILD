cc_binary(
    name = "client_binary",
    srcs = ["client.cc"],
    data = ["//proto/examples/routeguide:routeguide_features"],
    deps = ["//cc/examples/routeguide:helper"],
)

load("@io_bazel_rules_docker//cc:image.bzl", "cc_image")

cc_image(
    name = "client-image",
    binary = ":client_binary",
)

NAME = "cc-client"

BACKEND = "//cc/examples/routeguide/server"

load("//prod:cluster_consts.bzl", "REGISTRY", "PROJECT")

image_base = "%s/%s/hello-outeguide-%s:" % (REGISTRY, PROJECT, NAME)

IMAGE_NAME = image_base + "this_tag_will_be_replaced"

load("@io_bazel_rules_jsonnet//jsonnet:jsonnet.bzl", "jsonnet_to_json")

jsonnet_to_json(
    name = "json",
    src = "client.jsonnet",
    outs = ["client.json"],
    deps = [
        "@kube_jsonnet//:kube_lib",
        "//prod:envs",
    ],
    # json files are flat so we only need a variable to point to its contents.
    ext_code_file_vars = ["backend_service"],
    ext_code_files = [BACKEND + ":service.json"],
    ext_code = {"params": "%s" % {
        "image_name": IMAGE_NAME,
        "name": NAME,
    }},
)

load("@k8s_job//:defaults.bzl", "k8s_job")
load("@io_bazel_rules_k8s//k8s:objects.bzl", "k8s_objects")
load("@k8s_object//:defaults.bzl", "k8s_object")

k8s_job(
    name = "client",
    template = ":client.json",
    # Tell rules_k8s to
    # 1. Build the image, 2. push it, 3. get the SHA1 then 4. replace the
    # LOCAL_IMAGE_NAME used in the json's container with a reference to
    # the locally built one by its SHA.
    images = {IMAGE_NAME: ":client-image"},
)

# Shallow targets only spin up this service and deployment
k8s_objects(
    name = "shallow",
    objects = [":client"],
)

# Deep targets recursivly pull in all dependencies for sandbox/integration testing
k8s_objects(
    name = "deep",
    objects = [
        ":client",
        BACKEND + ":deep",
    ],
    visibility = ["//visibility:public"],
)
