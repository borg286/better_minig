package(default_visibility = ["//visibility:public"])

java_binary(
    name = "server-binary",
    main_class = "com.examples.grpc_redis.HelloServer",
    srcs = ["HelloServer.java"],
    deps = [
        "//proto/helloworld:java",
        "//proto/helloworld:java_compile_imports",
        "@org_pubref_rules_protobuf//java:netty_runtime_deps",
        "@org_redisson_redisson//jar",
    ],
    runtime_deps = ["//third_party/redisson:deps"],
)

load("@io_bazel_rules_docker//java:image.bzl", "java_image")
java_image(
    name = "server-image",
    main_class = "com.examples.grpc_redis.HelloServer",
    srcs = ["HelloServer.java"],
    deps = [
        "//proto/helloworld:java",
        "//proto/helloworld:java_compile_imports",
        "@org_pubref_rules_protobuf//java:netty_runtime_deps",
        "@org_redisson_redisson//jar",
    ],
    runtime_deps = ["//third_party/redisson:deps"],
)

load("//rules:envs.bzl","PROD", "STAGING", "DEV", "LOCAL", "makeDeepShallowTargets")

# Both the kubernetes json as well as the k8s_deploy need to know the image.
# This section fixes the docker image tags for each environment as the soure of truth.
# The k8s_deploy only needs it so that it can know where to push the -image target above.
# It is preferred to put as much as possible in the .jsonnet as possible. Only put here
# what needs to get shared between targets as strings. 
image_base = "gcr.io/fiery-orb-681/grpc-java-redis-server:"
images = {
    PROD: image_base + "my_prod_sha",
    STAGING: image_base + "my_staging_sha",
    DEV: image_base + "my_dev_sha",
    LOCAL: "localhost:5000/fiery-orb-681/grpc-java-redis-server:random-tag"
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

makeDeepShallowTargets(
    name_prefix = "server",
    image_url = images[LOCAL]
)
  
