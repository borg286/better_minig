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
package(default_visibility = ["//visibility:public"])

licenses(["notice"])  # Apache 2.0

load("@io_bazel_rules_docker//cc:image.bzl", "cc_image")

cc_binary(
    name = "server-binary",
    srcs = ["main.cc"],
    deps = ["//proto/helloworld:cc"],
)

cc_image(
    name = "server-image",
    binary = ":server-binary",
)

image = "us.gcr.io/not-my-project/hello-grpc-cc:staging"
port = "50001"

load("@io_bazel_rules_jsonnet//jsonnet:jsonnet.bzl", "jsonnet_to_json")
jsonnet_to_json(
    name = "kube-service",
    src = "server.jsonnet",
    outs = ["server.json", "service.json"],
    multiple_outputs = 1,
    ext_code_files = ["@kube_jsonnet//:kube_lib"],
    ext_code_file_vars = ["kube"],
)

load("@k8s_deploy//:defaults.bzl", "k8s_deploy")
load("@k8s_service//:defaults.bzl", "k8s_service")
load("@io_bazel_rules_k8s//k8s:objects.bzl", "k8s_objects")

k8s_deploy(
    name = "deployment",
    images = {
        image: ":server-image",
    },
    template = ":server.json",
)

k8s_service(
    name = "service",
    template = ":service.json",
)

k8s_objects(
    name = "server",
    objects = [
        ":deployment",
        ":service",
    ],
)

