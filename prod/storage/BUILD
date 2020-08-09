package(default_visibility = ["//visibility:public"])


load("@k8s_object//:defaults.bzl", "k8s_object")
load("@io_bazel_rules_k8s//k8s:objects.bzl", "k8s_objects")

k8s_object(
    name = "storage_local",
    template = ":local-path-storage.yaml",
)
k8s_objects(
    name = "storage",
    objects = [":storage_local"]
)
