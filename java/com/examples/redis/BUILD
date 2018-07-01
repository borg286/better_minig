package(default_visibility = ["//visibility:public"])

java_library(
    name = "lib",
    srcs = ["MyRedis.java"],
    deps = [
        "@org_redisson_redisson//jar",
    ],
    runtime_deps = ["//third_party/redisson:deps"],
)

java_binary(
    name = "server",
    main_class = "com.examples.redis.MyRedis",
    runtime_deps = [":lib"],
)
