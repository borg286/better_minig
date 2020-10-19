package(default_visibility = ["//visibility:public"])

SETUP = {
  "crds": "@minio//:operator-kustomize/crds/minio.min.io_tenants.yaml",
  "namespace": "@minio//:operator-kustomize/namespace.yaml",
}

MAIN = {
  "cluster-role-binding": "@minio//:operator-kustomize/cluster-role-binding.yaml",
  "cluster-role": "@minio//:operator-kustomize/cluster-role.yaml",
  "deployment": "@minio//:operator-kustomize/deployment.yaml",
  "service-account": "@minio//:operator-kustomize/service-account.yaml",
  "service": "@minio//:operator-kustomize/service.yaml",
}

load("@k8s_object//:defaults.bzl", "k8s_object")

# Definitions for running the minio operator.
[k8s_object(
    name = name,
    template = file,
) for name, file in SETUP.items()]

[k8s_object(
    name = name,
    template = file,
) for name, file in MAIN.items()]

# Use operator to define a minio cluster
k8s_object(
    name = "minio_k8s",
    template = "minio.yaml",
)

load("@io_bazel_rules_k8s//k8s:objects.bzl", "k8s_objects")

k8s_objects(
    name = "minio-setup",
    objects = [name for name in SETUP.keys()]
)

k8s_objects(
    name = "minio-operator",
    objects = [name for name in MAIN.keys()]
)

k8s_objects(
    name = "minio",
    objects = ["minio_k8s", ":minio-operator"]
)
