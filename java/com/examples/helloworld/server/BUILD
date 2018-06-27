package(default_visibility = ["//visibility:public"])

licenses(["notice"])  # Apache 2.0

load("@io_bazel_rules_docker//java:image.bzl", "java_image")

java_image(
    name = "server",
    srcs = ["HelloServer.java"],
    main_class = "com.examples.helloworld.server.HelloServer",
    deps = [
        "//proto/helloworld:java",
        "//proto/helloworld:java_compile_imports",
        "@org_pubref_rules_protobuf//java:netty_runtime_deps",
    ],
)

load("@k8s_deploy//:defaults.bzl", "k8s_deploy")

k8s_deploy(
    name = "deployment",
    images = {
        "us.gcr.io/not-my-project/hello-grpc:staging": ":server",
    },
    template = ":deployment_json",
)

load("@io_bazel_rules_jsonnet//jsonnet:jsonnet.bzl", "jsonnet_to_json")

jsonnet_to_json(
    name = "deployment_json",
    src = "deployment.jsonnet",
    outs = ["deployment.json"],
    ext_code_files = ["//prod:container_lib", "//prod:deploy_lib"],
    ext_code_file_vars = ["container", "deployment"],
)

load("@k8s_service//:defaults.bzl", "k8s_service")

k8s_service(
    name = "service",
    template = ":service_json",
)

jsonnet_to_json(
    name = "service_json",
    src = "service.jsonnet",
    outs = ["service.json"],
    ext_code_files = ["//prod:service_lib"],
    ext_code_file_vars = ["service"],
)


load("@io_bazel_rules_k8s//k8s:objects.bzl", "k8s_objects")

k8s_objects(
    name = "deployment_service",
    objects = [
        ":deployment",
        ":service",
    ],
)
