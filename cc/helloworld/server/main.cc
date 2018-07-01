// Copyright 2017 The Bazel Authors. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#include <iostream>
#include <memory>
#include <string>

#include <grpc++/grpc++.h>

#include "proto/helloworld/simple.pb.h"
#include "proto/helloworld/simple.grpc.pb.h"

using grpc::Server;
using grpc::ServerBuilder;
using grpc::ServerContext;
using grpc::Status;
using proto::FooRequest;
using proto::FooReply;
using proto::Simple;

// Logic and data behind the server's behavior.
class SimpleServiceImpl final : public Simple::Service {
  Status Foo(ServerContext* context, const FooRequest* request,
	     FooReply* reply) override {
    std::string prefix("DEMO ");
    reply->set_message(prefix + request->name());
    return Status::OK;
  }
};

void RunServer(char* port) {
  // TODO(mattmoor): port should be a flag.
  std::string server_address("0.0.0.0:");
  SimpleServiceImpl service;

  ServerBuilder builder;
  // Listen on the given address without any authentication mechanism.
  builder.AddListeningPort(server_address + port, grpc::InsecureServerCredentials());
  // Register "service" as the instance through which we'll communicate with
  // clients. In this case it corresponds to an *synchronous* service.
  builder.RegisterService(&service);
  // Finally assemble the server.
  std::unique_ptr<Server> server(builder.BuildAndStart());
  std::cout << "Server listening on " << server_address + port << std::endl;

  // Wait for the server to shutdown. Note that some other thread must be
  // responsible for shutting down the server for this call to ever return.
  server->Wait();
}

int main(int argc, char** argv) {
  if (argc < 2)
    return -1;
  std::cout << "WOrds " << argv[1] << std::endl;


  RunServer(argv[1]);

  return 0;
}
