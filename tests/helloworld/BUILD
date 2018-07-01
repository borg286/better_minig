load("@io_bazel_rules_go//go:def.bzl", "go_binary", "go_test")

go_binary(
    name = "silly",
    srcs = ["silly.go"],
    importpath = "github.com/borg286/better_minig/tests/helloworld",
)

go_test(
    name = "wrapper_test",
    srcs = ["process.go"],
    args = ["$(location :silly)"],
    importpath = "github.com/borg286/better_minig/tests/helloworld-tester",
    deps = [":silly"],
)
