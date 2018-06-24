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

load("@io_bazel_rules_docker//java:image.bzl", "java_image")

java_image(
    name = "client",
    srcs = ["HelloClient.java"],
    main_class = "com.examples.helloworld.client.HelloClient",
    deps = [
        "//proto/helloworld:java",
        "//proto/helloworld:java_compile_imports",
        "@org_pubref_rules_protobuf//java:netty_runtime_deps",
    ],
)


load("@io_bazel_rules_docker//container:container.bzl", "container_push")

container_push(
   name = "client_push",
   image = ":client",
   format = "Docker",
   registry = "gcr.io",
   repository = "redis-mrmath-test-1/helloworld/client",
   tag = "dev2",
)
