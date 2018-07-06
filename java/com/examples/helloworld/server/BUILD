package(default_visibility = ["//visibility:public"])

java_binary(
    name = "server-binary",
    main_class = "com.examples.helloworld.server.HelloServer",
    srcs = ["HelloServer.java"],
    deps = [
        "//proto/helloworld:java",
        "//proto/helloworld:java_compile_imports",
        "@org_pubref_rules_protobuf//java:netty_runtime_deps",
    ],
)

load("@io_bazel_rules_docker//java:image.bzl", "java_image")
java_image(
    name = "server-image",
    main_class = "com.examples.helloworld.server.HelloServer",
    srcs = ["HelloServer.java"],
    deps = [
        "//proto/helloworld:java",
        "//proto/helloworld:java_compile_imports",
        "@org_pubref_rules_protobuf//java:netty_runtime_deps",
    ],
)

load("//rules:envs.bzl","PROD", "STAGING", "DEV", "LOCAL", "ALL")

# Both the kubernetes json as well as the k8s_deploy need to know the image.
# This section fixes the docker image tags for each environment as the soure of truth.
# The k8s_deploy only needs it so that it can know where to push the -image target above.
# It is preferred to put as much as possible in the .jsonnet as possible. Only put here
# what needs to get shared between targets as strings. 
image_base = "us.gcr.io/some-prod-project/hello-grpc-java:"
images = {
    PROD: image_base + "my_prod_sha",
    STAGING: image_base + "my_staging_sha",
    DEV: image_base + "my_dev_sha",
    LOCAL: "us.gcr.io/my-developer-project/hello-grpc-java"
}
port = "50001"

load("@io_bazel_rules_jsonnet//jsonnet:jsonnet.bzl", "jsonnet_to_json")
jsonnet_to_json(
    name = "kube-service",
    src = "server.jsonnet",
    outs = ["prod-server.json", "staging-server.json", "dev-server.json", "local-server.json", "service.json"],
    multiple_outputs = 1,
    ext_code = {"images": "%s"%images, "port": port},
    ext_code_files = ["@kube_jsonnet//:kube_lib"],
    ext_code_file_vars = ["kube"],
)

load("@k8s_deploy//:defaults.bzl", "k8s_deploy")
load("@k8s_service//:defaults.bzl", "k8s_service")
load("@io_bazel_rules_k8s//k8s:objects.bzl", "k8s_objects")

k8s_service(
    name = "service",
    template = ":service.json",
)

[k8s_deploy(
    name = "%s-deployment"%env,
    # Only tell k8s_deploy to look for and push the docker image for a local run
    images = {} if env != LOCAL else {images[LOCAL]: ":server-image"},
    template = ":%s-server.json"%env,) for env in ALL]

[k8s_objects(
    name = "%s-server"%env,
    objects = [
        ":%s-deployment"%env,
        ":service",
    ],) for env in ALL]
