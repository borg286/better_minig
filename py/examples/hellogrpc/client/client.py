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

f = open('/tmp/1_starting', 'w')
f.write('sd')
f.close()
print("importing grpc")

import grpc
import sys

f = open('/tmp/2_trying_to_import_proto', 'w')
f.write('sd')
f.close()

print("importing proto files")

from proto.helloworld import simple_pb2
from proto.helloworld import simple_pb2_grpc


f = open('/tmp/3_defining_run', 'w')
f.write('sd')
f.close()

def run():
  try:
    print("running")
    f = open('/tmp/4_creating_channel', 'w')
    f.write('sd')
    f.close()
    channel = grpc.insecure_channel(sys.argv[1] + ':' + sys.argv[2])

    f = open('/tmp/5_creating_stub', 'w')
    f.write('sd')
    f.close()

    stub = simple_pb2_grpc.SimpleStub(channel)

    f = open('/tmp/6_calling_foo', 'w')
    f.write('sd')
    f.close()

    print("calling Foo")

    response = stub.Foo(simple_pb2.FooRequest(name='world'))
    f = open('/tmp/7_response_foo', 'w')
    f.write(response)
    f.close()
    print("done calling foo")

  except Error as e:
    message = "Error: {0}".format(e)
    f = open('tmp/error', 'w')
    f.write(message)
    f.close()
    print(message)

if __name__ == '__main__':
  run()
