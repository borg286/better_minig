PROD = "prod"
STAGING = "staging"
DEV = "dev"
LOCAL = "local"
ALL = [PROD, STAGING, DEV, LOCAL]

load("@k8s_deploy//:defaults.bzl", "k8s_deploy")
load("@io_bazel_rules_k8s//k8s:objects.bzl", "k8s_objects")
load("@k8s_object//:defaults.bzl", "k8s_object")


def makeDeepShallowTargets(image_url="", image_target=":server-image", deps_templates=[], prod_json=":prod-server.json", staging_json=":staging-server.json", dev_json=":dev-server.json", local_json=":local-server.json", env_independent_jsons={"myservice":("service",":service.json")}):

  # deps_template = [
    # "//some/runtime/service/dependency"
    # Note that the :target is missing due to this block assumming
    # the name of the target, ie. it relies on targets being named
    # in the way it is itself producing them.
  # ]

  [k8s_object(
    name = name,
    kind = kind_json[0],
    template = kind_json[1],
  ) for name, kind_json in env_independent_jsons.items()]

  k8s_deploy(
    name = "prod-deployment",
    template = prod_json,)
  k8s_deploy(
    name = "staging-deployment",
    template = staging_json,)
  k8s_deploy(
    name = "dev-deployment",
    template = dev_json,)
  k8s_deploy(
    name = "local-deployment",
    # Only tell k8s_deploy to look for and push the docker image for a local run
    images = {image_url: image_target},
    template = prod_json,)



  DEEP = "deep"
  SHALLOW = "shallow"
  # Produce groups of json for deploying this service
  # Shallow groups only deploy the job and service itself, and assumes all dependent services are up.
  # Deep groups embed the json needed to spin up all dependencies in 1 go.
  # This allows us to have build-time targets that recursivly capture all runtime-dependencies.
  # We repeat these groups for all environments.
  # Note that the LOCAL environment depends on the :server-image as well as all dependencies.
  # Thus by creating/updating a LOCAL group you effectivly run everything at head.
  [[k8s_objects(
    name = "%s-server-%s"%(env,depth),
    objects = [
        ":%s-deployment"%env,
    ] + [
        ":%s"%name for name in env_independent_jsons.keys()
    # If defining a shallow group just capture above k8s stuff, else
    ] + [] if depth != DEEP else [
        # use the dependency template strings above to construct a build target
        # that mirrors the environment and fetches the deep group.
        dep + ":%s-server-%s"%(env,DEEP) for dep in deps_templates],
    ) for env in ALL] for depth in (SHALLOW, DEEP)]

