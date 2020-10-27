package(default_visibility = ["//visibility:public"])
load("@k8s_object_with_namespace//:defaults.bzl", "k8s_object_with_namespace")
load("//jsonnet:yaml_to_json.bzl", "yaml_to_json")

SETUP = {
  "io_spinnakeraccounts_crd": "@spinnaker-operator//:deploy/crds/spinnaker.io_spinnakeraccounts_crd.yaml",
  "io_spinnakerservices_crd": "@spinnaker-operator//:deploy/crds/spinnaker.io_spinnakerservices_crd.yaml",
  #"role": "@spinnaker-operator//:deploy/operator/basic/role.yaml",
  #"service_account": "@spinnaker-operator//:deploy/operator/basic/service_account.yaml",
}

OPERATOR = {
  "role_binding": "@spinnaker-operator//:deploy/operator/basic/role_binding.yaml",
  "deployment": "@spinnaker-operator//:deploy/operator/basic/deployment.yaml",
  "operator-role": "@spinnaker-operator//:deploy/role.yaml",
  "role": "@spinnaker-operator//:deploy/operator/cluster/role.yaml",
  "service_account": "@spinnaker-operator//:deploy/operator/cluster/service_account.yaml",
  #"role_binding": "@spinnaker-operator//:deploy/operator/cluster/role_binding.yaml",
  #"deployment": "@spinnaker-operator//:deploy/operator/cluster/deployment.yaml",
}

yaml_to_json(
    name = "spinnakerservice_unpatched_json",
    #src = "@spinnaker-operator//:deploy/spinnaker/basic/spinnakerservice.yml",
    src = "@spinnaker-operator//:deploy/spinnaker/complete/spinnakerservice.yml",
)

load("@io_bazel_rules_jsonnet//jsonnet:jsonnet.bzl", "jsonnet_to_json")

jsonnet_to_json(
    name = "spinnaker_json",
    src = "spinnaker.jsonnet",
    outs = ["spinnaker.json"],
    ext_code_file_vars = ["spinnaker_unpatched"],
    ext_code_files = [":spinnakerservice_unpatched_json"],
)

k8s_object_with_namespace(
    name = "init-config-map",
    kind = "ConfigMap",
    template = "init.yaml",
)

k8s_object_with_namespace(
    name = "operator-namespace",
    kind = "namespace",
    template = "operator-namespace.json",
)
k8s_object_with_namespace(
    name = "namespace",
    kind = "namespace",
    template = "namespace.json",
)


[k8s_object_with_namespace(
    name = name,
    template = yaml,
) for name, yaml in SETUP.items()]

[k8s_object_with_namespace(
    name = name,
    #namespace = "spinnaker-operator",
    template = yaml,
) for name, yaml in OPERATOR.items()]


k8s_object_with_namespace(
    name = "spinnaker_k8s",
    #namespace = "spinnaker",
    template = ":spinnaker_json",
)

load("@io_bazel_rules_k8s//k8s:objects.bzl", "k8s_objects")

k8s_objects(
    name = "setup",
    objects = [":namespace", ":operator-namespace"] + 
              [name for name in SETUP.keys()] +
              ["init-config-map"]
)

k8s_objects(
    name = "operator",
    objects = [name for name in OPERATOR.keys()]
)

k8s_objects(
    name = "spinnaker",
    objects = [":spinnaker_k8s"]
)
