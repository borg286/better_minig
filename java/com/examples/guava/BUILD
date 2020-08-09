package(default_visibility = ["//visibility:public"])

java_library(
    name = "JavaDependency",
    srcs = ["Library.java"],
    deps = [
        # These are external dependencies that are
        # defined in the top-level WORKSPACE file.
        "@maven//:org_apache_commons_commons_lang3",
        "@maven//:com_google_guava_guava",
    ],
)
