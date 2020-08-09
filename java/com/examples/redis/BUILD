
java_library(
    name = "lib",
    srcs = ["RedissonExample.java"],
    deps = [
        "@maven//:org_redisson_redisson_all",
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
        "@maven//:redis_clients_jedis",
        "@maven//:org_slf4j_slf4j_api",
        "@maven//:org_slf4j_slf4j_simple",
        "@maven//:org_apache_commons_commons_pool2",
    ],
)
