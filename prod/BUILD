package(default_visibility = ["//visibility:public"])

load("@io_bazel_rules_jsonnet//jsonnet:jsonnet.bzl", "jsonnet_to_json", "jsonnet_library")
load(":cluster_consts.bzl", "PROD", "STAGING", "DEV", "MYNS", "ENVS", "user")

# This is a custom rule that tries to fetch the $USER from the environment.
# Bazel only allows environment variables to pass through when building with
# --action_env=USER  is used. I recommend putting that in the .bazelrc file.
# build --action_env=USER
user(name = "current-user")

jsonnet_to_json(
    name = "namespaces",
    src = "namespaces.jsonnet",
    outs = ["%s.json" % env for env in ENVS],
    multiple_outputs = 1,
    deps = [
        "@kube_jsonnet//:kube_lib",
        ":envs",
    ],
    ext_code_file_vars = ["user"],
    ext_code_files = [":current-user.txt"],
    ext_code = {"params": "%s" % {"envs": ENVS}},
)

load("@k8s_object//:defaults.bzl", "k8s_object")

[k8s_object(
    name = "%s" % env,
    kind = "namespace",
    template = ":%s.json" % env,
) for env in ENVS]

jsonnet_to_json(
    name = "environment_names",
    src = "dummy.jsonnet",
    outs = ["environment_names.json"],
    ext_code_file_vars = ["user"],
    ext_code_files = [":current-user.txt"],
    ext_code = {"ret": "%s" % {
        "prod": PROD,
        "staging": STAGING,
        "dev": DEV,
    }},
)

jsonnet_library(
    name = "envs",
    srcs = ["envs.libsonnet"],
    data = ["environment_names.json"],
)


jsonnet_to_json(
    name = "registry",
    src = "registry.jsonnet",
    outs = ["registry-depl.json", "registry-svc.json"],
    deps = ["@kube_jsonnet//:kube_lib"],
)

load("@k8s_object//:defaults.bzl", "k8s_object")
load("@io_bazel_rules_k8s//k8s:objects.bzl", "k8s_objects")

k8s_object(
    name = "registry-depl",
    template = ":registry-depl.json",
)
k8s_object(
    name = "registry-svc",
    template = ":registry-svc.json",
)
k8s_objects(
    name = "local-registry",
    objects = [":registry-depl", ":registry-svc"],
)



k8s_object(
    name = "storage_class",
    template = "storage.yaml",
)
k8s_objects(
    name = "storage",
    objects = [":storage_class"]
)



