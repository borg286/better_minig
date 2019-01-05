
java_library(
    name = "lib",
    srcs = ["RedissonExample.java"],
    deps = [
        "@org_redisson_redisson//jar",
    ],
)

java_binary(
    name = "server",
    main_class = "com.examples.redis.RedissonExample",
    runtime_deps = [":lib"],
)


java_binary(
    name = "jedis",
    main_class = "com.examples.redis.JedisExample",
    srcs = ["JedisExample.java"],
    deps = [
        "@jedis//jar",
        "@org_slf4j_api//jar",
        "@org_slf4j_simple//jar",
        "@org_apache_commons//jar",
    ],
)
