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

load("//rules:envs.bzl","PROD", "STAGING", "DEV", "LOCAL", "makeDeepShallowTargets")

# Both the kubernetes json as well as the k8s_deploy need to know the image.
# This section fixes the docker image tags for each environment as the soure of truth.
# The k8s_deploy only needs it so that it can know where to push the -image target above.
# It is preferred to put as much as possible in the .jsonnet as possible. Only put here
# what needs to get shared between targets as strings. 
image_base = "us.gcr.io/some-prod-project/hello-grpc-cc:"
images = {
    PROD: image_base + "my_prod_sha",
    STAGING: image_base + "my_staging_sha",
    DEV: image_base + "my_dev_sha",
    LOCAL: "us.gcr.io/my-developer-project/hello-grpc-cc"
}
port = "50001"

load("@io_bazel_rules_jsonnet//jsonnet:jsonnet.bzl", "jsonnet_to_json")
jsonnet_to_json(
    name = "kube-service",
    src = "server.jsonnet",
    outs = ["prod-server.json", "staging-server.json", "dev-server.json", "local-server.json", "service.json"],
    multiple_outputs = 1,
    ext_code = {"images": "%s"%images, "port": port},
    ext_code_files = ["@kube_jsonnet//:kube_lib"],
    ext_code_file_vars = ["kube"],
)

makeDeepShallowTargets(
    image_url = images[LOCAL]
)

