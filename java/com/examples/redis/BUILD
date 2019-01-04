
java_library(
    name = "lib",
    srcs = ["MyRedis.java"],
    deps = [
        "@org_redisson_redisson//jar",
    ],
)

java_binary(
    name = "server",
    main_class = "com.examples.redis.MyRedis",
    runtime_deps = [":lib"],
)
