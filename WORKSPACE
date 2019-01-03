workspace(name = "fresh")

load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository", "new_git_repository")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")


#####################################################
#########     Docker image bases          ###########
#####################################################

# Download the rules_docker repository at release v0.6.0
http_archive(
    name = "io_bazel_rules_docker",
    sha256 = "c0e9d27e6ca307e4ac0122d3dd1df001b9824373fb6fb8627cd2371068e51fef",
    strip_prefix = "rules_docker-0.6.0",
    urls = ["https://github.com/bazelbuild/rules_docker/archive/v0.6.0.tar.gz"],
)

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

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# You *must* import the Go rules before setting up the go_image rules.
git_repository(
    name = "io_bazel_rules_go",
    tag = "0.16.5",
    remote = "https://github.com/bazelbuild/rules_go.git",
)

load(
    "@io_bazel_rules_docker//go:image.bzl",
    _go_image_repos = "repositories",
)

_go_image_repos()

load(
    "@io_bazel_rules_docker//java:image.bzl",
    _java_image_repos = "repositories",
)

_java_image_repos()

############################################################################
##############                   GRPC                    ###################
############################################################################

http_archive(
    name = "bazel_toolchains",
    sha256 = "4329663fe6c523425ad4d3c989a8ac026b04e1acedeceb56aa4b190fa7f3973c",
    strip_prefix = "bazel-toolchains-bc09b995c137df042bb80a395b73d7ce6f26afbe",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/bazel-toolchains/archive/bc09b995c137df042bb80a395b73d7ce6f26afbe.tar.gz",
        "https://github.com/bazelbuild/bazel-toolchains/archive/bc09b995c137df042bb80a395b73d7ce6f26afbe.tar.gz",
    ],
)

git_repository(
    name = "build_stack_rules_proto",
    commit = "e68d8b625dd6e59a64a25a7f1acd0f875b3d8b86",
    remote = "https://github.com/stackb/rules_proto.git",
)

######  java   #######

load("@build_stack_rules_proto//:deps.bzl",
    "io_grpc_grpc_java",
)

io_grpc_grpc_java()

load("@io_grpc_grpc_java//:repositories.bzl", "grpc_java_repositories")

grpc_java_repositories(omit_com_google_protobuf = True)

load("@build_stack_rules_proto//java:deps.bzl", "java_grpc_library")

java_grpc_library()

######   go    #######

load("@build_stack_rules_proto//go:deps.bzl", "go_grpc_library")
go_grpc_library()

load("@io_bazel_rules_go//go:def.bzl",
    "go_register_toolchains",
    "go_rules_dependencies"
)
go_rules_dependencies()
go_register_toolchains()


#####   python   ####

load("@build_stack_rules_proto//python:deps.bzl", "python_grpc_library")

python_grpc_library()

load("@com_github_grpc_grpc//bazel:grpc_deps.bzl", "grpc_deps")

grpc_deps()

load("@io_bazel_rules_python//python:pip.bzl", "pip_import", "pip_repositories")

pip_repositories()

# For each python package that we want available in our requirements.txt file
# we have a text file with contents of the line that would have gone into the
# requirements.txt file.  We then do a pip_import of that file, and then
# call load on the bzl file the import produces. This load will create a function
# that can call to do the actual import.
pip_import(
    name = "protobuf_py_deps",
    requirements = "//py/requirements:protobuf.txt",
)
load("@protobuf_py_deps//:requirements.bzl", protobuf_pip_install = "pip_install")
protobuf_pip_install()

pip_import(
    name = "grpc_py_deps",
    requirements = "//py:requirements.txt",
)
load("@grpc_py_deps//:requirements.bzl", grpc_pip_install = "pip_install")
grpc_pip_install()


###### cpp   ########


load("@build_stack_rules_proto//cpp:deps.bzl", "cpp_grpc_library")

cpp_grpc_library()

load("@com_github_grpc_grpc//bazel:grpc_deps.bzl", "grpc_deps")

grpc_deps()


#############################################################
############          Maven imports           ###############
#############################################################

# Imported from Redisson dependencies
maven_jar(
    name = "org_redisson_redisson",
    artifact = "org.redisson:redisson:3.7.3",
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
maven_jar(
    name = "org_springframework_data_redis",
    artifact = "org.springframework.data:spring-data-redis:2.0.9.RELEASE",
)


# Flag library

maven_jar(
    name = "com_github_pcj_google_options",
    artifact = "com.github.pcj:google-options:jar:1.0.0",
    sha1 = "85d54fe6771e5ff0d54827b0a3315c3e12fdd0c7",
)

# gson (json encoding and decoding)
maven_jar(
    name = "com_google_code_gson",
    artifact = "com.google.code.gson:gson:2.8.5",
)

# protobuf
maven_jar(
    name = "my_com_google_protobuf",
    artifact = "com.google.protobuf:protobuf-java-util:3.6.1",
)

# Joda time
maven_jar(
    name = "joda_time",
    artifact = "joda-time:joda-time:2.10",
)


#####################################################
#########  Imports for go repos on github   #########
#####################################################

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

#####################################################
#########     Kubernetes  Imports         ###########
#####################################################

git_repository(
    name = "io_bazel_rules_k8s",
    commit = "bc9a60a1250af9856c4797aebd79bb08bee370f5",
    remote = "https://github.com/bazelbuild/rules_k8s.git",
)

load("@io_bazel_rules_k8s//k8s:k8s.bzl", "k8s_repositories")

k8s_repositories()
load("@io_bazel_rules_k8s//k8s:k8s.bzl", "k8s_defaults")

load("//prod:cluster_consts.bzl", "REGISTRY", "CLUSTER", "PROJECT")

k8s_defaults(
  name = "k8s_deploy",
  kind = "deployment",
  cluster = CLUSTER,
)
k8s_defaults(
  name = "k8s_job",
  kind = "job",
  cluster = CLUSTER,
)

k8s_defaults(
  name = "k8s_object",
  cluster = CLUSTER,
)

#############################################################
############          Jsonnet                 ###############
#############################################################

# We use jsonnet to configure the kubernetes deployments, services...

git_repository(
    name = "io_bazel_rules_jsonnet",
    commit = "f39f5fd8c9d8ae6273cd6d8610016a561d4d1c95",
    remote = "https://github.com/bazelbuild/rules_jsonnet.git",
)

load("@io_bazel_rules_jsonnet//jsonnet:jsonnet.bzl", "jsonnet_repositories")

jsonnet_repositories()

http_archive(
    name = "kube_jsonnet",
    url = "https://github.com/bitnami-labs/kube-libsonnet/archive/7107df489817715d01b0c29088f4bbf5c4696aaa.tar.gz",
    strip_prefix = "kube-libsonnet-7107df489817715d01b0c29088f4bbf5c4696aaa",
    build_file_content = """
package(default_visibility = ["//visibility:public"])
load("@io_bazel_rules_jsonnet//jsonnet:jsonnet.bzl", "jsonnet_library")

jsonnet_library(
    name = "kube_lib",
    srcs = ["kube.libsonnet"],
)
""",
)

