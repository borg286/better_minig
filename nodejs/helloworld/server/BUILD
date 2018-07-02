package(default_visibility = ["//visibility:public"])

load("@io_bazel_rules_docker//nodejs:image.bzl", "nodejs_image")

nodejs_image(
    name = "server",
    data = [":server.js"],
    entry_point = "better_minig/nodejs/helloworld/server.js",
    node_modules = "@nodejs_helloworld_npm//:node_modules",
)

