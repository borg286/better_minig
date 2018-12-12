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
"""Python hellogrpc client implementation."""

import grpc
import sys

from proto.helloworld import simple_pb2
from proto.helloworld import simple_pb2_grpc


def run():
    print("creating channel to " + sys.argv[1] + ':' + sys.argv[2])
    channel = grpc.insecure_channel(sys.argv[1] + ':' + sys.argv[2])
    print("Creating stub")
    stub = simple_pb2_grpc.SimpleStub(channel)
    print("calling service")
    response = stub.Foo(simple_pb2.FooRequest(name='world'))
    print("Foo(world): " + response.message)

if __name__ == '__main__':
    print("running")
    run()
