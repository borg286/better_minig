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
package main

import (
	"flag"
	"context"
	"fmt"
	"log"
	"os"

	pb "github.com/bazelbuild/rules_k8s/examples/hellogrpc/proto/go"
	"google.golang.org/grpc"
)

var port = flag.String("grpc_server", "50051", "port to send requests to")

func main() {
	flag.Parse()
	ctx := context.Background()

	if len(os.Args) != 2 {
		log.Fatalf("Expected a single IP argument")
	}

	addr := os.Args[1]

	conn, err := grpc.Dial(fmt.Sprintf("%s:%s", addr, port), grpc.WithInsecure())
	if err != nil {
		log.Fatalf("Dial: %v", err)
	}
	defer conn.Close()

	client := pb.NewSimpleClient(conn)

	fooRep, err := client.Foo(ctx, &pb.FooRequest{
		Name: "world",
	})
	if err != nil {
		log.Fatalf("Foo: %v", err)
	}
	fmt.Printf("Foo(%s): %s\n", "world", fooRep.Message)
}
