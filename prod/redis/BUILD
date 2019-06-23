package(default_visibility = ["//visibility:public"])

load(":redis.bzl", "redis")
load("//prod:cluster_consts.bzl", "ENVS")


[redis(
  name = "grpc-redis",
  env = env,
) for env in ENVS]
