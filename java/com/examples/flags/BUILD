java_binary(
    name = "server",
    main_class = "com.examples.flags.Server",
    srcs = glob(["*.java"]),
    deps = [
        "@maven//:com_github_pcj_google_options",
        "@maven//:com_google_guava_guava",
    ],
    args = [
        "--host",
        "localhost",
        "--port",
        "8081",
        "--dir",
        "www/",
        "--dir",
        "resources/",
    ],
    visibility = ["//visibility:public"],
)
