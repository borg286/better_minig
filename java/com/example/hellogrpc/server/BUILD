package(default_visibility = ["//visibility:public"])

load("@io_bazel_rules_docker//java:image.bzl", "java_image")

java_image(
    name = "server",
    srcs = ["HelloServer.java"],
    main_class = "com.examples.hellogrpc.server.HelloServer",
    deps = [
        "//proto/hellogrpc:java",
        "//proto/hellogrpc:java_compile_imports",
        "@org_pubref_rules_protobuf//java:netty_runtime_deps",
    ],
)

load("@k8s_deploy//:defaults.bzl", "k8s_deploy")

k8s_deploy(
    name = "staging",
    images = {
        "brian.com/hello-grpc:staging": ":server",
    },
    template = "//prod/hellogrpc:deployment.json",
)

