
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository", "new_git_repository")



git_repository(
    name = "rules_python",
    remote = "https://github.com/bazelbuild/rules_python.git",
    commit = "38f86fb55b698c51e8510c807489c9f4e047480e",
)


#=====Docker images======

# Download the rules_docker repository at release v0.12.1
http_archive(
    name = "io_bazel_rules_docker",
    sha256 = "14ac30773fdb393ddec90e158c9ec7ebb3f8a4fd533ec2abbfd8789ad81a284b",
    strip_prefix = "rules_docker-0.12.1",
    urls = ["https://github.com/bazelbuild/rules_docker/releases/download/v0.12.1/rules_docker-v0.12.1.tar.gz"],
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
    commit = "6264dec9b1464817cc7c954b957823f33c19d838",
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
load("@io_grpc_grpc_java//:repositories.bzl", "grpc_java_repositories")
grpc_java_repositories(
    omit_bazel_skylib = True,
    omit_com_google_protobuf = True,
    omit_com_google_protobuf_javalite = True,
    omit_net_zlib = True,
)


#======= END GRPC =======


#=======   K8S =======

git_repository(
    name = "io_bazel_rules_k8s",
    commit = "aaf9e025990c8a9ca5bc19faaa2010641eba5738",
    remote = "https://github.com/bazelbuild/rules_k8s.git",
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




load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")
http_file(
    name = "storage_deployment",
    urls = ["https://raw.githubusercontent.com/MaZderMind/hostpath-provisioner/master/manifests/deployment.yaml"],
    sha256 = "336e7700d086a124e25623f001bf65af366ef9801637a28a56401a786bab824e",
    downloaded_file_path = "deployment.yaml",
)
http_file(
    name = "storage_rbac",
    urls = ["https://raw.githubusercontent.com/MaZderMind/hostpath-provisioner/master/manifests/rbac.yaml"],
    sha256 = "1974787bf11272cfdac28885b863dfa885afd5134fe5a187a6a34b6fe0e09dba",
    downloaded_file_path = "rbac.yaml",
)
http_file(
    name = "storage_storageclass",
    urls = ["https://raw.githubusercontent.com/MaZderMind/hostpath-provisioner/master/manifests/storageclass.yaml"],
    sha256 = "472c26dd70bfbd92db890f1f7d5f68474b2388864f60fcd2c05f1aa2a0737467",
    downloaded_file_path = "storageclass.yaml"
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

# Imported from Redisson dependencies
maven_jar(
    name = "org_redisson_redisson",
    artifact = "org.redisson:redisson-all:3.10.0",
    sha256 = "360a430acf4bb5992fa41834ac49f94626988254e1abcdc7d97c7e1530e076fa",
    sha256_src = "5ff6499d19d0e26cf0564f511bc07365df85fd53c5cacc36395ebab140b3257c",
)

maven_jar(
    name = "jedis",
    artifact = "redis.clients:jedis:3.0.0",
    sha256 = "f31df05826147840153ac4429925b85f6540ad00cc81c311e4b11b0a964ce98b",
    sha256_src = "99441a8a226d460438a34a2ae6c3c387fea3de276c317b39f4e4aaca7c306948",
)

maven_jar(
    name = "org_slf4j_api",
    artifact = "org.slf4j:slf4j-api:1.7.25",
    sha256 = "18c4a0095d5c1da6b817592e767bb23d29dd2f560ad74df75ff3961dbde25b79",
    sha256_src = "c4bc93180a4f0aceec3b057a2514abe04a79f06c174bbed910a2afb227b79366",
)

maven_jar(
    name = "org_slf4j_simple",
    artifact = "org.slf4j:slf4j-simple:1.7.25",
    sha256_src = "2cfa254e77c6f41bdcd8500c61c0f6b9959de66835d2b598102d38c2a807f367",
    sha256 = "0966e86fffa5be52d3d9e7b89dd674d98a03eed0a454fbaf7c1bd9493bd9d874",
)


maven_jar(
    name = "org_apache_commons",
    artifact = "org.apache.commons:commons-pool2:2.4.3",
    sha256 = "d6ce7f6ab4341eb1da6139006b287fcd2cf8553abcfb018c0906224815fc9245",
    sha256_src = "c3334aa4ee68836b9bcb0887d9c8be14620d3850aab740e2e6635f8eee9356fe",
)

# Flag library

maven_jar(
    name = "com_github_pcj_google_options",
    artifact = "com.github.pcj:google-options:jar:1.0.0",
    sha256 = "f1f84449b46390a7fa73aac0b5acdec4312d6174146af0db1c92425c7005fdce",
    sha256_src = "3871275e5323aaa132ed043c3c3bf6620f5fe73c8aeb456ce992db9ce5d59768",
)

# gson (json encoding and decoding)
maven_jar(
    name = "com_google_code_gson",
    artifact = "com.google.code.gson:gson:2.8.5",
    sha256 = "233a0149fc365c9f6edbd683cfe266b19bdc773be98eabdaf6b3c924b48e7d81",
    sha256_src = "512b4bf6927f4864acc419b8c5109c23361c30ed1f5798170248d33040de068e",
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

#======== End Maven java imports


#======== Monitoring configs =====

new_git_repository(
    name = "monitoring",
    remote = "https://github.com/coreos/kube-prometheus.git",
    commit = "9493a1a5f7090dca406a0e80d1986484c70c1acf",
    build_file = "//prod:BUILD.yaml-extraction",
)


go_repository(
    name = "gojsontoyaml",
    commit = "bf2969bbd742d117a9524b859fb417fefb67565d",
    importpath = "github.com/brancz/gojsontoyaml",
)

#======== End Monitoring configs ====
