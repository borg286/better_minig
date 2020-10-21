load("@io_bazel_rules_jsonnet//jsonnet:jsonnet.bzl", "jsonnet_to_json")
load("@io_bazel_rules_k8s//k8s:objects.bzl", "k8s_objects")
load("@k8s_object//:defaults.bzl", "k8s_object")
load("//prod:cluster_consts.bzl", "REGISTRY", "PROJECT")


def redis(name):
  args = {"name":name}

  image_base = "%s/%s/redis-bootstrap:" % (REGISTRY, PROJECT)

  LOCAL_IMAGE_NAME = image_base + "this_tag_will_be_replaced_wahoo"

  jsonnet_to_json(
    name = "{name}-json".format(**args),
    src = "redis.jsonnet",
    outs = [s.format(**args) for s in [
      "{name}-statefulset.json",
      "{name}-svc.json",
      "{name}-conf.json",
    ]],
    multiple_outputs = True,
    deps = [
      "@kube_jsonnet//:kube_lib",
      "//jsonnet:utils",
    ],
    # stringify a python map (with arbitrary nesting) then let jsonnet parse into json map.
    ext_code = {"params": "%s" % {
      "image_base": image_base,
      "local_image_name": LOCAL_IMAGE_NAME,
      "name": name,
    }},
  )
  
  k8s_object(
    name = "{name}_service".format(**args),
    kind = "service",
    template = ":{name}-svc.json".format(**args),
  )
  k8s_object(
    name = "{name}_conf".format(**args),
    kind = "ConfigMap",
    template = ":{name}-conf.json".format(**args),
  )

  k8s_object(
    name = "{name}_statefulset".format(**args),
    kind = "statefulset",
    template = ":{name}-statefulset.json".format(**args),
    images = {LOCAL_IMAGE_NAME: "//prod/redis:bootstrap-image"} ,
  )
 
  k8s_objects(
    name = "{name}".format(**args),
    objects = [
      ":{name}_statefulset".format(**args),
      ":{name}_service".format(**args),
      ":{name}_conf".format(**args),
    ],
  )



