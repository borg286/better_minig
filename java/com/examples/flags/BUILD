java_binary(
    name = "server",
    main_class = "com.examples.flags.Server",
    srcs = glob(["*.java"]),
    deps = [
        "@com_github_pcj_google_options//jar",
        "@com_google_guava_guava//jar",
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
