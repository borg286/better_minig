workspace(name = "brian")

# ================================================================
# Imports for examples/
# ================================================================

git_repository(
    name = "org_pubref_rules_protobuf",
    tag = "v0.8.2",
    remote = "https://github.com/pubref/rules_protobuf.git",
)

load("@org_pubref_rules_protobuf//protobuf:rules.bzl", "proto_repositories")

proto_repositories()

load("@org_pubref_rules_protobuf//cpp:rules.bzl", "cpp_proto_repositories")

cpp_proto_repositories()

load("@org_pubref_rules_protobuf//java:rules.bzl", "java_proto_repositories")

java_proto_repositories()






git_repository(
    name = "io_bazel_rules_docker",
    commit = "27c94dec66c3c9fdb478c33994471c5bfc15b6eb",
#    tag = "v0.4.0",
    remote = "https://github.com/bazelbuild/rules_docker.git",
)

load(
    "@io_bazel_rules_docker//docker:docker.bzl",
    "docker_repositories",
)

docker_repositories()

git_repository(
    name = "io_bazel_rules_k8s",
    commit = "8537afcc8728e5ebfafa9b68462e54a98935d06b",
    remote = "https://github.com/bazelbuild/rules_k8s.git",
)

load("@io_bazel_rules_k8s//k8s:k8s.bzl", "k8s_repositories")


new_http_archive(
    name = "mock",
    build_file_content = """
# Rename mock.py to __init__.py
genrule(
    name = "rename",
    srcs = ["mock.py"],
    outs = ["__init__.py"],
    cmd = "cat $< >$@",
)
py_library(
   name = "mock",
   srcs = [":__init__.py"],
   visibility = ["//visibility:public"],
)""",
    sha256 = "b839dd2d9c117c701430c149956918a423a9863b48b09c90e30a6013e7d2f44f",
    strip_prefix = "mock-1.0.1/",
    type = "tar.gz",
    url = "https://pypi.python.org/packages/source/m/mock/mock-1.0.1.tar.gz",
)

# We use cc_image to build a sample service
load(
    "@io_bazel_rules_docker//cc:image.bzl",
    _cc_image_repos = "repositories",
)

_cc_image_repos()

# We use java_image to build a sample service
load(
    "@io_bazel_rules_docker//java:image.bzl",
    _java_image_repos = "repositories",
)

_java_image_repos()

git_repository(
    name = "io_bazel_rules_go",
    tag = "0.12.1",
    remote = "https://github.com/bazelbuild/rules_go.git",
)

load(
    "@io_bazel_rules_go//go:def.bzl",
    "go_rules_dependencies", "go_register_toolchains",
)

go_rules_dependencies()
go_register_toolchains()

# We use go_image to build a sample service
load(
    "@io_bazel_rules_docker//go:image.bzl",
    _go_image_repos = "repositories",
)

_go_image_repos()

load("@org_pubref_rules_protobuf//go:rules.bzl", "go_proto_repositories")

go_proto_repositories()

git_repository(
    name = "io_bazel_rules_python",
    commit = "3e167dcfb17356c68588715ed324c5e9b76f391d",
    remote = "https://github.com/bazelbuild/rules_python.git",
)


# We use py_image to build a sample service
load(
    "@io_bazel_rules_docker//python:image.bzl",
    _py_image_repos = "repositories",
)

_py_image_repos()

load("@org_pubref_rules_protobuf//python:rules.bzl", "py_proto_repositories")

py_proto_repositories()

git_repository(
    name = "io_bazel_rules_jsonnet",
    commit = "9cecb2e53ce539f35e1619e3935f7d3adee8ccdd",
    remote = "https://github.com/bazelbuild/rules_jsonnet.git",
)

# pip imports for placing requrements into build targets and also separate docker layers
load(
    "@io_bazel_rules_python//python:pip.bzl",
    "pip_import",
    "pip_repositories",
)
pip_repositories()


# Create a requirement() rule capable of layering python dependencies
# the libraries available to pass to requirement() is separate for each
# requirement.txt file in the repo

# requirements for general python code
pip_import(
    name = "py_pip",
    requirements = "//py:requirements.txt",
)
load(
    "@py_pip//:requirements.bzl",
    py_install = "pip_install",
)
py_install()




# We use jsonnet to configure the kubernetes deployments, services...

load("@io_bazel_rules_jsonnet//jsonnet:jsonnet.bzl", "jsonnet_repositories")

jsonnet_repositories()

new_http_archive(
    name = "kube_jsonnet",
    url = "https://github.com/bitnami-labs/kube-libsonnet/archive/d30a2d7fd5c6686b5a2aeda914533530e26019e0.tar.gz",
    strip_prefix = "kube-libsonnet-d30a2d7fd5c6686b5a2aeda914533530e26019e0",
	build_file_content = """
package(default_visibility = ["//visibility:public"])
filegroup(
    name = "kube_lib",
    srcs = ["kube.libsonnet"],
)""",
)



git_repository(
    name = "build_bazel_rules_nodejs",
    commit = "5c53b46110d13c4c9f22364e96b2d0f55896d7aa",
    remote = "https://github.com/bazelbuild/rules_nodejs.git",
)

load("@build_bazel_rules_nodejs//:defs.bzl", "node_repositories", "npm_install")

node_repositories(package_json = ["//examples/hellohttp/nodejs:package.json"])

# We use nodejs_image to build a sample service
load(
    "@io_bazel_rules_docker//nodejs:image.bzl",
    _nodejs_image_repos = "repositories",
)

_nodejs_image_repos()

npm_install(
    name = "examples_hellohttp_npm",
    package_json = "//examples/hellohttp/nodejs:package.json",
)

# ================================================================
# Imports for maven jars
# ================================================================

# Imported from Redisson dependencies
maven_jar(
    name = "org_redisson_redisson",
    artifact = "org.redisson:redisson:3.7.3",
)
maven_jar(
    name = "junit_junit",
    artifact = "junit:junit:4.12",
)

maven_jar(
    name = "io_netty_netty_transport_native_kqueue",
    artifact = "io.netty:netty-transport-native-kqueue:4.1.25.Final",
)

maven_jar(
    name = "io_netty_netty_transport_native_epoll",
    artifact = "io.netty:netty-transport-native-epoll:4.1.25.Final",
)
maven_jar(
    name = "io_netty_netty_resolver_dns",
    artifact = "io.netty:netty-resolver-dns:4.1.25.Final",
)
maven_jar(
    name = "io_netty_netty_codec_dns",
    artifact = "io.netty:netty-codec-dns:4.1.25.Final",
)
maven_jar(
    name = "javax_cache_cache_api",
    artifact = "javax.cache:cache-api:1.0.0",
)
maven_jar(
    name = "io_projectreactor_reactor_stream",
    artifact = "io.projectreactor:reactor-stream:2.0.8.RELEASE",
)
maven_jar(
    name = "net_jpountz_lz4_lz4",
    artifact = "net.jpountz.lz4:lz4:1.3.0",
)
maven_jar(
    name = "org_msgpack_jackson_dataformat_msgpack",
    artifact = "org.msgpack:jackson-dataformat-msgpack:0.8.16",
)
maven_jar(
    name = "de_ruedigermoeller_fst",
    artifact = "de.ruedigermoeller:fst:2.54",
)
maven_jar(
    name = "com_esotericsoftware_kryo",
    artifact = "com.esotericsoftware:kryo:4.0.1",
)
maven_jar(
    name = "org_slf4j_slf4j_api",
    artifact = "org.slf4j:slf4j-api:1.7.25",
)
maven_jar(
    name = "com_fasterxml_jackson_dataformat_jackson_dataformat_yaml",
    artifact = "com.fasterxml.jackson.dataformat:jackson-dataformat-yaml:2.7.9",
)
maven_jar(
    name = "com_fasterxml_jackson_core_jackson_core",
    artifact = "com.fasterxml.jackson.core:jackson-core:2.9.5",
)
maven_jar(
    name = "com_fasterxml_jackson_core_jackson_annotations",
    artifact = "com.fasterxml.jackson.core:jackson-annotations:2.9.5",
)
maven_jar(
    name = "com_fasterxml_jackson_core_jackson_databind",
    artifact = "com.fasterxml.jackson.core:jackson-databind:2.9.5",
)
maven_jar(
    name = "com_fasterxml_jackson_dataformat_jackson_dataformat_ion",
    artifact = "com.fasterxml.jackson.dataformat:jackson-dataformat-ion:2.9.5",
)
maven_jar(
    name = "com_fasterxml_jackson_dataformat_jackson_dataformat_cbor",
    artifact = "com.fasterxml.jackson.dataformat:jackson-dataformat-cbor:2.9.5",
)
maven_jar(
    name = "com_fasterxml_jackson_dataformat_jackson_dataformat_smile",
    artifact = "com.fasterxml.jackson.dataformat:jackson-dataformat-smile:2.9.5",
)
maven_jar(
    name = "com_fasterxml_jackson_dataformat_jackson_dataformat_avro",
    artifact = "com.fasterxml.jackson.dataformat:jackson-dataformat-avro:2.9.5",
)
maven_jar(
    name = "net_bytebuddy_byte_buddy",
    artifact = "net.bytebuddy:byte-buddy:1.8.11",
)
maven_jar(
    name = "org_jodd_jodd_bean",
    artifact = "org.jodd:jodd-bean:3.7.1",
)
maven_jar(
    name = "org_springframework_spring_context",
    artifact = "org.springframework:spring-context:5.0.7.RELEASE",
)
maven_jar(
    name = "org_springframework_spring_context_support",
    artifact = "org.springframework:spring-context-support:5.0.7.RELEASE",
)
maven_jar(
    name = "org_springframework_spring_tx",
    artifact = "org.springframework:spring-tx:5.0.7.RELEASE",
)
maven_jar(
    name = "org_springframework_session_spring_session",
    artifact = "org.springframework.session:spring-session:1.2.2.RELEASE",
)
maven_jar(
    name = "org_springframework_boot_spring_boot_actuator",
    artifact = "org.springframework.boot:spring-boot-actuator:2.0.3.RELEASE",
)

# Apache Commons

maven_jar(
  name = "org_apache_commons_commons_lang3",
  artifact = "org.apache.commons:commons-lang3:3.7",
)


# ================================================================
# Imports for go repos on github
# ================================================================



load("@bazel_gazelle//:deps.bzl", "gazelle_dependencies")
gazelle_dependencies()
load("@bazel_gazelle//:deps.bzl", "go_repository")

go_repository(
    name = "gomodule_redigo",
    commit = "2cd21d9966bf7ff9ae091419744f0b3fb0fecace",
    importpath = "github.com/gomodule/redigo",
)


load("@io_bazel_rules_k8s//k8s:k8s.bzl", "k8s_repositories")

k8s_repositories()
load("@io_bazel_rules_k8s//k8s:k8s.bzl", "k8s_defaults")

# have this match the output from
# kubectl config current-context
_CLUSTER = "gke_redis-mrmath-test-1_us-central1-a_cluster-1"
_PROJECT = "redis-mrmath-test-1"
_NAMESPACE = "{BUILD_USER}"

k8s_defaults(
  name = "k8s_deploy",
  kind = "deployment",
  image_chroot = "us.gcr.io/" + _PROJECT + "/{BUILD_USER}",
  cluster = _CLUSTER,
)

k8s_defaults(
  name = "k8s_service",
  kind = "service",
  cluster = _CLUSTER,

)
k8s_defaults(
  name = "k8s_job",
  kind = "job",
  image_chroot = "us.gcr.io/" + _PROJECT + "/{BUILD_USER}",
  cluster = _CLUSTER,
)

