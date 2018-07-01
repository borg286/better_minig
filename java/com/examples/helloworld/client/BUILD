package(default_visibility = ["//visibility:public"])

java_library(
    name = "client-lib",
    srcs = ["HelloClient.java"],
    deps = [
        "//proto/helloworld:java",
        "//proto/helloworld:java_compile_imports",
        "@org_pubref_rules_protobuf//java:netty_runtime_deps",
    ],
)

java_binary(
    name = "client-binary",
    main_class = "com.examples.helloworld.client.HelloClient",
    runtime_deps = [":client-lib"],
)

load("@io_bazel_rules_docker//java:image.bzl", "java_image")
java_image(
    name = "client-image",
    main_class = "com.examples.helloworld.client.HelloClient",
    runtime_deps = [":client-lib"],
)

image = "us.gcr.io/not-my-project/hello-grpc-java-client:staging"

load("@io_bazel_rules_jsonnet//jsonnet:jsonnet.bzl", "jsonnet_to_json")
jsonnet_to_json(
    name = "kube-job",
    src = "job.jsonnet",
    outs = ["job.json"],
    multiple_outputs = 1,
    ext_code_files = ["@kube_jsonnet//:kube_lib", "//java/com/examples/helloworld/server:service.json"],
    ext_code_file_vars = ["kube", "server"],
)

load("@k8s_job//:defaults.bzl", "k8s_job")
k8s_job(
    name = "job",
    images = {
        image: ":client-image",
    },
    template = ":job.json",
)
