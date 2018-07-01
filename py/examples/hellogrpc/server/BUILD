package(default_visibility = ["//visibility:public"])

load("@py_pip//:requirements.bzl", "requirement")
load("@io_bazel_rules_docker//python:image.bzl", "py_image")

py_image(
    name = "server",
    srcs = ["server.py"],
    # "layers" is just like "deps", but it also moves the dependencies each into
    # their own layer, which can dramatically improve developer cycle time.  For
    # example here, the grpcio layer is ~40MB, but the rest of the app is only
    # ~400KB.  By partitioning things this way, the large grpcio layer remains
    # unchanging and we can reduce the amount of image data we repush by ~99%!
    layers = [
        requirement("grpcio"),
        requirement("setuptools"),

        "//proto/helloworld:py",
    ],
    main = "server.py",
)

