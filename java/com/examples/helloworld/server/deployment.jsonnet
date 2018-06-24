local deployment = std.extVar("deployment");
local container = std.extVar("container");

deployment.Simple("hello-grpc-staging",
	          container.Simple(
		     "hello-grpc",
		     "us.gcr.io/not-my-project/hello-grpc:staging",
		     50051))
