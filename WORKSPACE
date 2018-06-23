# =========================================
# Imports for piping binary targets into docker images
# =========================================

git_repository(
    name = "io_bazel_rules_docker",
    commit = "27c94dec66c3c9fdb478c33994471c5bfc15b6eb",
    remote = "https://github.com/bazelbuild/rules_docker.git",
)

load(
    "@io_bazel_rules_docker//docker:docker.bzl",
    "docker_repositories",
)

docker_repositories()

# =========================================
# Imports for piping docker references in kubernetes yaml files
# =========================================

git_repository(
    name = "io_bazel_rules_k8s",
    commit = "8537afcc8728e5ebfafa9b68462e54a98935d06b",
    remote = "https://github.com/bazelbuild/rules_k8s.git",
)

load("@io_bazel_rules_k8s//k8s:k8s.bzl", "k8s_repositories", "k8s_defaults")

k8s_repositories()

_NAMESPACE = "{BUILD_USER}"

# Create aliases for k8s rules to have default values.

k8s_defaults(
    name = "k8s_object",
#    image_chroot = "localhost:5000/{BUILD_USER}",
    namespace = _NAMESPACE,
)

k8s_defaults(
    name = "k8s_deploy",
    #image_chroot = "localhost:5000/{BUILD_USER}",
    kind = "deployment",
    namespace = _NAMESPACE,
)

k8s_defaults(
    name = "k8s_service",
    kind = "service",
    namespace = _NAMESPACE,
)



# =========================================
# Imports for go bazel rules
# =========================================

git_repository(
    name = "io_bazel_rules_go",
    commit = "ae70411645c171b2056d38a6a959e491949f9afe",
    remote = "https://github.com/bazelbuild/rules_go.git",
)

load(
    "@io_bazel_rules_go//go:def.bzl",
    "go_repositories",
)

go_repositories()


# =========================================
# Imports for node bazel rules
# =========================================

git_repository(
    name = "build_bazel_rules_nodejs",
    commit = "5c53b46110d13c4c9f22364e96b2d0f55896d7aa",
    remote = "https://github.com/bazelbuild/rules_nodejs.git",
)

load("@build_bazel_rules_nodejs//:defs.bzl", "node_repositories", "npm_install")


# ===============================
# Imports for proto
# Needs to be after go bazel rules
# ================================

git_repository(
    name = "org_pubref_rules_protobuf",
    commit = "4cc90ab2b9f4d829b9706221d4167bc7fb3bd247",  # patched v0.8.1 (Sep 27 2017)
    remote = "https://github.com/pubref/rules_protobuf.git",
)

load("@org_pubref_rules_protobuf//protobuf:rules.bzl", "proto_repositories")
proto_repositories()

load("@org_pubref_rules_protobuf//cpp:rules.bzl", "cpp_proto_repositories")
cpp_proto_repositories()

load("@org_pubref_rules_protobuf//java:rules.bzl", "java_proto_repositories")
java_proto_repositories()

load("@org_pubref_rules_protobuf//go:rules.bzl", "go_proto_repositories")
go_proto_repositories()



# ===============================
# Imports for base docker images
# ================================

load(
    "@io_bazel_rules_docker//cc:image.bzl",
    _cc_image_repos = "repositories",
)

_cc_image_repos()

load(
    "@io_bazel_rules_docker//java:image.bzl",
    _java_image_repos = "repositories",
)

_java_image_repos()

load(
    "@io_bazel_rules_docker//go:image.bzl",
    _go_image_repos = "repositories",
)

_go_image_repos()

load(
    "@io_bazel_rules_docker//nodejs:image.bzl",
    _nodejs_image_repos = "repositories",
)

_nodejs_image_repos()

# =========================================
# Imports for jsonnet templates
# =========================================

git_repository(
    name = "io_bazel_rules_jsonnet",
    commit = "09ec18db5b9ad3129810f5f0ccc86363a8bfb6be",
    remote = "https://github.com/bazelbuild/rules_jsonnet.git",
)

load("@io_bazel_rules_jsonnet//jsonnet:jsonnet.bzl", "jsonnet_repositories")

jsonnet_repositories()
