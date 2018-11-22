package(default_visibility = ["//visibility:public"])

load("@io_bazel_rules_docker//java:image.bzl", "java_image")
java_image(
    name = "client-image",
    main_class = "com.examples.helloworld.client.HelloClient",
    srcs = ["HelloClient.java"],
    deps = [
        "//proto/helloworld:java",
        "//proto/helloworld:java_compile_imports",
        "@org_pubref_rules_protobuf//java:netty_runtime_deps",
    ],
)

PROD = "prod"
STAGING = "staging"
DEV = "dev"
LOCAL = "local"

image_base = "localhost:5000/not-my-project/hello-grpc-java-client:"
images = {
    PROD: image_base + "my_prod_sha",
    STAGING: image_base + "my_staging_sha",
    DEV: image_base + "my_dev_sha",
    LOCAL: "localhost:5000/my-developer-project/hello-grpc-java-client:some-tag"
}


load("@io_bazel_rules_jsonnet//jsonnet:jsonnet.bzl", "jsonnet_to_json")
jsonnet_to_json(
    name = "json",
    src = "job.jsonnet",
    outs = ["prod-job.json", "staging-job.json", "dev-job.json", "local-job.json"],
    multiple_outputs = 1,
    ext_code = {"images": "%s"%images},
    ext_code_files = ["@kube_jsonnet//:kube_lib", "//java/com/examples/helloworld/server:service.json"],
    ext_code_file_vars = ["kube", "server"],
)

load("@k8s_deploy//:defaults.bzl", "k8s_deploy")
load("@io_bazel_rules_k8s//k8s:objects.bzl", "k8s_objects")
load("@k8s_object//:defaults.bzl", "k8s_object")


k8s_object(
  name = "prod-job",
  kind = "job",
  template = ":prod-job.json"
)
k8s_object(
  name = "staging-job",
  kind = "job",
  template = ":staging-job.json"
)
k8s_object(
  name = "dev-job",
  kind = "job",
  template = ":dev-job.json"
)
k8s_object(
  name = "local-job",
  kind = "job",
  # Only tell k8s_deploy to look for and push the docker image for a local run
  images = {images[LOCAL]: ":client-image"},
  template = ":local-job.json"
)


# Shallow targets only spin up this service and deployment
k8s_objects(
  name = "prod-shallow",
  objects = [":prod-job"],
)
k8s_objects(
  name = "staging-shallow",
  objects = [":staging-job"],
)
k8s_objects(
  name = "dev-shallow",
  objects = [":dev-job"],
)
k8s_objects(
  name = "local-shallow",
  objects = [":local-job"],
)



# Deep targets recursivly pull in all dependencies for sandbox/integration testing
k8s_objects(
  name = "prod-deep",
  objects = [":prod-job", "//java/com/examples/helloworld/server:prod-deep"],
)
k8s_objects(
  name = "staging-deep",
  objects = [":staging-job", "//java/com/examples/helloworld/server:staging-deep"],
)
k8s_objects(
  name = "dev-deep",
  objects = [":dev-job", "//java/com/examples/helloworld/server:dev-deep"],
)
k8s_objects(
  name = "local-deep",
  objects = [":local-job", "//java/com/examples/helloworld/server:local-deep"],
)





