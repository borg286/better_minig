load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository", "new_git_repository")



#=====Docker images======

# Download the rules_docker repository at release v0.12.1
http_archive(
    name = "io_bazel_rules_docker",
    sha256 = "4521794f0fba2e20f3bf15846ab5e01d5332e587e9ce81629c7f96c793bb7036",
    strip_prefix = "rules_docker-0.14.4",
    urls = ["https://github.com/bazelbuild/rules_docker/releases/download/v0.14.4/rules_docker-v0.14.4.tar.gz"],
)


load(
    "@io_bazel_rules_docker//repositories:repositories.bzl",
    container_repositories = "repositories",
)
container_repositories()

# This is NOT needed when going through the language lang_image
# "repositories" function(s).
load("@io_bazel_rules_docker//repositories:deps.bzl", container_deps = "deps")

container_deps()


load("@io_bazel_rules_docker//repositories:pip_repositories.bzl", "pip_deps")

pip_deps()

load(
    "@io_bazel_rules_docker//container:container.bzl",
    "container_pull",
)

container_pull(
  name = "java_base",
  registry = "gcr.io",
  repository = "distroless/java",
  # 'tag' is also supported, but digest is encouraged for reproducibility.
  digest = "sha256:deadbeef",
)
load(
    "@io_bazel_rules_docker//repositories:repositories.bzl",
    container_repositories = "repositories",
)
container_repositories()

load(
    "@io_bazel_rules_docker//go:image.bzl",
    _go_image_repos = "repositories",
)
_go_image_repos()


load(
    "@io_bazel_rules_docker//cc:image.bzl",
    _cc_image_repos = "repositories",
)
_cc_image_repos()


load(
    "@io_bazel_rules_docker//python:image.bzl",
    _py_image_repos = "repositories",
)
_py_image_repos()

load(
    "@io_bazel_rules_docker//java:image.bzl",
    _java_image_repos = "repositories",
)
_java_image_repos()


load("@io_bazel_rules_docker//container:container.bzl", "container_pull",)
container_pull(
    name = "redis-base",
    registry = "index.docker.io",
    repository = "redis",
    digest = "sha256:e73ef998c22f9a98793d9951bb2915cd945d8fa6f9ec1b324e85d19617efc2fd",
)

#====== END Docker images==========


#====== GRPC  ==============

git_repository(
    name = "rules_proto_grpc",
    commit = "aeb1f82225e53e756765a4da761adf0c85112a54",
    remote = "https://github.com/rules-proto-grpc/rules_proto_grpc.git",
)

load("@rules_proto_grpc//:repositories.bzl", "rules_proto_grpc_toolchains", "rules_proto_grpc_repos")
rules_proto_grpc_toolchains()
rules_proto_grpc_repos()



load("@rules_proto_grpc//:repositories.bzl", "bazel_gazelle", "io_bazel_rules_go")

io_bazel_rules_go()

load("@io_bazel_rules_go//go:deps.bzl", "go_register_toolchains", "go_rules_dependencies")

go_rules_dependencies()

go_register_toolchains()

bazel_gazelle()

load("@bazel_gazelle//:deps.bzl", "gazelle_dependencies")

gazelle_dependencies()

load("@rules_proto_grpc//go:repositories.bzl", rules_proto_grpc_go_repos="go_repos")

rules_proto_grpc_go_repos()
load("@rules_proto_grpc//cpp:repositories.bzl", rules_proto_grpc_cpp_repos="cpp_repos")

rules_proto_grpc_cpp_repos()

load("@com_github_grpc_grpc//bazel:grpc_deps.bzl", "grpc_deps")

grpc_deps()



load("@rules_proto_grpc//python:repositories.bzl", rules_proto_grpc_python_repos="python_repos")

rules_proto_grpc_python_repos()

load("@com_github_grpc_grpc//bazel:grpc_deps.bzl", "grpc_deps")

grpc_deps()


load("@rules_python//python:repositories.bzl", "py_repositories")
py_repositories()

load("@rules_python//python:pip.bzl", "pip_repositories")
pip_repositories()

load("@rules_python//python:pip.bzl", "pip_import")
pip_import(
    name = "rules_proto_grpc_py2_deps",
    python_interpreter = "python",
    requirements = "@rules_proto_grpc//python:requirements.txt",
)

load("@rules_proto_grpc_py2_deps//:requirements.bzl", pip2_install="pip_install")
pip2_install()

pip_import(
    name = "rules_proto_grpc_py3_deps",
    python_interpreter = "python3",
    requirements = "@rules_proto_grpc//python:requirements.txt",
)
load("@rules_proto_grpc_py3_deps//:requirements.bzl", pip3_install="pip_install")
pip3_install()



load("@rules_proto_grpc//java:repositories.bzl", rules_proto_grpc_java_repos="java_repos")
rules_proto_grpc_java_repos()

load("@bazel_tools//tools/build_defs/repo:jvm.bzl", "jvm_maven_import_external")
jvm_maven_import_external(
    name = "io_netty_netty_common",
    artifact = "io.netty:netty-common:4.1.51.Final",
    server_urls = ["https://repo.maven.apache.org/maven2/"],
    licenses = ["notice"],  # Apache 2.0
)
jvm_maven_import_external(
    name = "io_netty_netty_tcnative_boringssl_static",
    artifact = "io.netty:netty-tcnative-boringssl-static:2.0.30.Final",
    server_urls = ["https://repo.maven.apache.org/maven2/"],
    artifact_sha256 = "61934ca753be47973fe427d1f483a1b2fbcaf56eefc71519bf35fddb036ee111",
    licenses = ["notice"],  # Apache 2.0
)

load("@io_grpc_grpc_java//:repositories.bzl", "grpc_java_repositories")
grpc_java_repositories(
    omit_bazel_skylib = True,
    omit_com_google_protobuf = True,
    omit_com_google_protobuf_javalite = True,
    omit_net_zlib = True,
)


#======= END GRPC =======

#=======   K8S =======

# This requires rules_docker to be fully instantiated before
# it is pulled in.
# Download the rules_k8s repository at release v0.4
http_archive(
    name = "io_bazel_rules_k8s",
    sha256 = "d91aeb17bbc619e649f8d32b65d9a8327e5404f451be196990e13f5b7e2d17bb",
    strip_prefix = "rules_k8s-0.4",
    urls = ["https://github.com/bazelbuild/rules_k8s/releases/download/v0.4/rules_k8s-v0.4.tar.gz"],
)

load("@io_bazel_rules_k8s//k8s:k8s.bzl", "k8s_repositories")

k8s_repositories()

load("@io_bazel_rules_k8s//k8s:k8s_go_deps.bzl", k8s_go_deps = "deps")

k8s_go_deps()

load("//prod:cluster_consts.bzl", "REGISTRY", "CLUSTER", "PROJECT")
load("@io_bazel_rules_k8s//k8s:k8s.bzl", "k8s_defaults")

k8s_defaults(
  name = "k8s_deploy",
  cluster = CLUSTER,
  kind = "deployment",
)
k8s_defaults(
  name = "k8s_job",
  cluster = CLUSTER,
  kind = "job",
)

k8s_defaults(
  name = "k8s_object",
  cluster = CLUSTER,
)


#====== END K8S ======


#====== JSONNET  =====
# We use jsonnet to configure the kubernetes deployments, services...

git_repository(
    name = "io_bazel_rules_jsonnet",
    commit = "12979862ab51358a8a5753f5a4aa0658fec9d4af",
    remote = "https://github.com/bazelbuild/rules_jsonnet.git",
)

load("@io_bazel_rules_jsonnet//jsonnet:jsonnet.bzl", "jsonnet_repositories")

jsonnet_repositories()

http_archive(
    name = "kube_jsonnet",
    url = "https://github.com/bitnami-labs/kube-libsonnet/archive/96b30825c33b7286894c095be19b7b90687b1ede.tar.gz",
    strip_prefix = "kube-libsonnet-96b30825c33b7286894c095be19b7b90687b1ede",
    build_file_content = """
package(default_visibility = ["//visibility:public"])
load("@io_bazel_rules_jsonnet//jsonnet:jsonnet.bzl", "jsonnet_library")

jsonnet_library(
    name = "kube_lib",
    srcs = ["kube.libsonnet"],
)
""",
)
#======= END JSONNET  ======

#======= Imports for go repos on github ===============

http_archive(
    name = "bazel_gazelle",
    urls = ["https://github.com/bazelbuild/bazel-gazelle/releases/download/0.16.0/bazel-gazelle-0.16.0.tar.gz"],
    sha256 = "7949fc6cc17b5b191103e97481cf8889217263acf52e00b560683413af204fcb",
)
load("@bazel_gazelle//:deps.bzl", "gazelle_dependencies", "go_repository")
gazelle_dependencies()

go_repository(
    name = "gomodule_redigo",
    commit = "2cd21d9966bf7ff9ae091419744f0b3fb0fecace",
    importpath = "github.com/gomodule/redigo",
)

#======= END Imports of go repos =======================

#======== Maven java imports   ========


RULES_JVM_EXTERNAL_TAG = "3.3"
RULES_JVM_EXTERNAL_SHA = "d85951a92c0908c80bd8551002d66cb23c3434409c814179c0ff026b53544dab"

http_archive(
    name = "rules_jvm_external",
    strip_prefix = "rules_jvm_external-%s" % RULES_JVM_EXTERNAL_TAG,
    sha256 = RULES_JVM_EXTERNAL_SHA,
    url = "https://github.com/bazelbuild/rules_jvm_external/archive/%s.zip" % RULES_JVM_EXTERNAL_TAG,
)

load("@rules_jvm_external//:defs.bzl", "maven_install")

maven_install(
    artifacts = [
        # Imported from Redisson dependencies
        "org.redisson:redisson-all:3.13.3",
        "redis.clients:jedis:3.0.0",
        "org.slf4j:slf4j-api:1.7.25",
        "org.slf4j:slf4j-simple:1.7.25",
        "org.apache.commons:commons-pool2:2.4.3",
        "org.apache.commons:commons-lang3:3.11",
        #"io.netty:netty-tcnative-boringssl-static:2.0.31.Final",
        #"io.netty:netty-all:4.1.41.Final",

        # Flag library
        "com.github.pcj:google-options:jar:1.0.0",
        "com.google.code.gson:gson:2.8.5",
        "com.google.protobuf:protobuf-java-util:3.6.1",

        # Joda time
        "joda-time:joda-time:2.10",
    ],
    repositories = [
        "https://repo1.maven.org/maven2",
        "https://mvnrepository.com",
    ],
)
#======== End Maven java imports


#======== Monitoring configs =====

new_git_repository(
    name = "monitoring",
    remote = "https://github.com/coreos/kube-prometheus.git",
    commit = "980e95de011319b88a3b9c0787a81dcdf338a898",
    build_file = "//prod:BUILD.yaml-extraction",
)


go_repository(
    name = "gojsontoyaml",
    commit = "3697ded27e8cfea8e547eb082ebfbde36f1b5ee6",
    importpath = "github.com/brancz/gojsontoyaml",
)

#======== End Monitoring configs ====

#========== Storage configs =========
new_git_repository(
    name = "minio",
    remote = "https://github.com/minio/operator.git",
    commit = "7fcd3543a41f54ddede7e46c6b97626bea1bc2b3",
    build_file = "//prod:BUILD.yaml-extraction",
)

#========= End Storage configs
