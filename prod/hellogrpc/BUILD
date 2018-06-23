package(default_visibility = ["//visibility:public"])

load("@k8s_deploy//:defaults.bzl", "k8s_deploy")

k8s_deploy(
    name = "staging-deployment",
    template = "deployment.yaml",
)

load("@k8s_service//:defaults.bzl", "k8s_service")

k8s_deploy(
    name = "staging-service",
    template = "service.yaml",
)

load("@io_bazel_rules_k8s//k8s:objects.bzl", "k8s_objects")

k8s_objects(
    name = "staging",
    objects = [
        ":staging-deployment",
        ":staging-service",
    ],
)

load("@io_bazel_rules_jsonnet//jsonnet:jsonnet.bzl", "jsonnet_to_json")

jsonnet_to_json(
    name = "deployment",
    src = "deployment.jsonnet",
    outs = ["deployment.json"],
    deps = [
        "//prod:container_lib",
        "//prod:deploy_lib",
    ],
)

