/*
 * Copyright 2017 The Bazel Authors. All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.examples.grpc_redis;

import io.grpc.Server;
import io.grpc.ServerBuilder;
import io.grpc.stub.StreamObserver;

import java.io.IOException;
import java.util.Collection;
import java.util.HashSet;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;
import java.util.logging.Logger;

import com.examples.helloworld.proto.SimpleGrpc;
import com.examples.helloworld.proto.FooRequest;
import com.examples.helloworld.proto.FooReply;

import org.redisson.Redisson;
import org.redisson.api.RMap;
import org.redisson.api.RedissonClient;
import org.redisson.api.RAtomicLong;
import org.redisson.config.Config;



public class HelloServer {
    private static final Logger logger = Logger.getLogger(HelloServer.class.getName());

    private final int port;
    private Server server;
    private RedissonClient redisson;
    private String redisServer;

    public HelloServer() {
	this(50051, "localhost");
    }

    public HelloServer(int port, String redisServer) {
	this.port = port;
        this.redisServer = redisServer;
    }

    public void start() throws IOException {
        Config config = new Config();
        config.useSingleServer().setAddress("redis://" + redisServer + ":6379");
        redisson = Redisson.create(config);

	server = ServerBuilder.forPort(port)
	    .addService(new SimpleImpl())
	    .build()
	    .start();
	logger.info("Server started, listening on " + port);
	Runtime.getRuntime().addShutdownHook(new Thread() {
		@Override
		public void run() {
		    // Use stderr here since the logger may have been reset by its JVM shutdown hook.
		    System.err.println("*** shutting down gRPC server since JVM is shutting down");
		    HelloServer.this.stop();
		    System.err.println("*** server shut down");
		}
	    });
    }

    public void stop() {
	if (server != null) {
	    server.shutdown();
	}
        if (redisson != null) {
            redisson.shutdown();
        }
    }

    /** Await termination on the main thread since the grpc library uses daemon threads. */
    private void blockUntilShutdown() throws InterruptedException {
	if (server != null) {
	    server.awaitTermination();
	}
    }

    /** Main launches the server from the command line. */
    public static void main(String[] args) throws Exception {
        final HelloServer server = new HelloServer(Integer.parseInt(args[0]), args[1]);
	server.start();
	server.blockUntilShutdown();
    }

    private class SimpleImpl extends SimpleGrpc.SimpleImplBase {
	@Override
	public void foo(FooRequest req, StreamObserver<FooReply> responseObserver) {
            System.out.println("I got a message");
            if (redisson != null) {
              RAtomicLong atomicLong = redisson.getAtomicLong(req.getName());
              FooReply reply = FooReply.newBuilder().setMessage("" + atomicLong.incrementAndGet()).build();
              responseObserver.onNext(reply);
            }
	    responseObserver.onCompleted();
	}
    }
}
