# Copyright 2017 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

workspace(name = "brian")


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

git_repository(
    name = "io_bazel_rules_k8s",
    commit = "8537afcc8728e5ebfafa9b68462e54a98935d06b",
    remote = "https://github.com/bazelbuild/rules_k8s.git",
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

# ================================================================
# Imports for examples/
# ================================================================

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
    commit = "ae70411645c171b2056d38a6a959e491949f9afe",
    remote = "https://github.com/bazelbuild/rules_go.git",
)

load(
    "@io_bazel_rules_go//go:def.bzl",
    "go_repositories",
)

go_repositories()

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
