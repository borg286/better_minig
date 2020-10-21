package(default_visibility = ["//visibility:public"])

load("@io_bazel_rules_jsonnet//jsonnet:jsonnet.bzl", "jsonnet_to_json", "jsonnet_library")
load(":cluster_consts.bzl", "ENVS")

# jsonnet library to encapsulate the environment we're building for,
#  specified by the K8S_ENV environment variable.
# We use jsonnet_to_json simply to hook in the stamped variable K8S_ENV and turn it into json
# so we can import it into a jsonnet library which can expose a jsonnet function.
jsonnet_to_json(
    name = "env_str",
    src = "env_wrapper.jsonnet",
    ext_strs = {
        "env": "{K8S_ENV}",
    },
    stamp_keys = ["env"],
    outs = ["env.json"]
)
jsonnet_library(
    name = "envs",
    srcs = ["envs.libsonnet"],
    imports = ["env_str"]
)

jsonnet_to_json(
    name = "json",
    src = "namespaces.jsonnet",
    outs = ["prod.json", "staging.json", "dev.json", "myns.json"],
    multiple_outputs = 1,
    deps = [
        "@kube_jsonnet//:kube_lib",
    ],
    ext_strs = {
        "user": "{BUILD_USER}"
    },
    stamp_keys = ["user"]
)

load("@k8s_object_with_namespace//:defaults.bzl", "k8s_object_with_namespace")

[k8s_object_with_namespace(
    name = "%s" % env,
    kind = "namespace",
    template = ":%s.json" % env,
) for env in ENVS]





jsonnet_to_json(
    name = "registry",
    src = "registry.jsonnet",
    outs = ["registry-depl.json", "registry-svc.json"],
    deps = ["@kube_jsonnet//:kube_lib"],
)

load("@io_bazel_rules_k8s//k8s:objects.bzl", "k8s_objects")

k8s_object_with_namespace(
    name = "registry-depl",
    template = ":registry-depl.json",
)
k8s_object_with_namespace(
    name = "registry-svc",
    template = ":registry-svc.json",
)
k8s_objects(
    name = "local-registry",
    objects = [":registry-depl", ":registry-svc"],
)

k8s_objects(
    name = "setup",
    objects = [":local-registry"] + 
              [":%s"%env for env in ENVS] +
              ["//prod/monitoring:monitoring-setup"] +
              ["//prod/storage/minio:minio-setup"],
)


k8s_object_with_namespace(
    name = "storage_class",
    template = "storage.yaml",
)
k8s_objects(
    name = "storage-setup",
    objects = [":storage_class"]
)



