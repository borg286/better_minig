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
load("//rules:envs.bzl","PROD", "STAGING", "DEV", "LOCAL", "makeDeepShallowTargets")

image_base = "localhost:5000/not-my-project/hello-grpc-java-client:"
images = {
    PROD: image_base + "my_prod_sha",
    STAGING: image_base + "my_staging_sha",
    DEV: image_base + "my_dev_sha",
    LOCAL: "localhost:5000/my-developer-project/hello-grpc-java-client:some-tag"
}


load("@io_bazel_rules_jsonnet//jsonnet:jsonnet.bzl", "jsonnet_to_json")
jsonnet_to_json(
    name = "kube-job",
    src = "job.jsonnet",
    outs = ["prod-job.json", "staging-job.json", "dev-job.json", "local-job.json"],
    multiple_outputs = 1,
    ext_code = {"images": "%s"%images},
    ext_code_files = ["@kube_jsonnet//:kube_lib", "//java/com/examples/helloworld/server:service.json"],
    ext_code_file_vars = ["kube", "server"],
)

makeDeepShallowTargets(
    name_prefix = "job",
    kind = "job",
    image_url = images[LOCAL],
    image_target = ":client-image",
    deps_templates = ["//java/com/examples/helloworld/server:server"],
    prod_json = ":prod-job.json",
    staging_json = ":staging-job.json",
    dev_json = ":dev-job.json",
    local_json = ":local-job.json",
    env_independent_jsons = {},
)


