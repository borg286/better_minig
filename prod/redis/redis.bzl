load("@io_bazel_rules_jsonnet//jsonnet:jsonnet.bzl", "jsonnet_to_json")
load("@io_bazel_rules_k8s//k8s:objects.bzl", "k8s_objects")
load("@k8s_object//:defaults.bzl", "k8s_object")


def redis(name, env):
  args = {"name":name, "env":env}
  jsonnet_to_json(
    name = "{name}-{env}-json".format(**args),
    src = "redis.jsonnet",
    outs = [s.format(**args) for s in [
      "{name}-{env}-statefulset.json",
      "{name}-{env}-config-map.json",
      "{name}-{env}-svc.json"
    ]],
    multiple_outputs = True,
    deps = [
      "@kube_jsonnet//:kube_lib",
      "//prod:envs",
      "//jsonnet:utils",
    ],
    # stringify a python map (with arbitrary nesting) then let jsonnet parse into json map.
    ext_code = {"params": "%s" % {
      "name": name,
      "env": env,
    }},
  )
  
  k8s_object(
    name = "{name}-{env}_service".format(**args),
    kind = "service",
    template = ":{name}-{env}-svc.json".format(**args),
  )

  k8s_object(
    name = "{name}-{env}_statefulset".format(**args),
    kind = "statefulset",
    template = ":{name}-{env}-statefulset.json".format(**args),
  )
  k8s_object(
    name = "{name}-{env}_config_map".format(**args),
    kind = "ConfigMap",
    template = ":{name}-{env}-config-map.json".format(**args),
  )
 
  k8s_objects(
    name = "{name}-{env}".format(**args),
    objects = [
      ":{name}-{env}_statefulset".format(**args),
      ":{name}-{env}_service".format(**args),
      ":{name}-{env}_config_map".format(**args),
    ],
  )



