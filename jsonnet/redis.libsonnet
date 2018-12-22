local kube = std.extVar("kube");
{
  redis(name):: kube.Deployment(name) {
      spec+: {
        replicas: 1,
        template+: {
          spec+: {
            containers_+: {
              gb_fe: kube.Container("redis") {
                image: "redis",
                resources: {},
                args: [],
                ports_+: { tcp: { containerPort: 6379 } },
  }}}}}},
  redisService(name, target+_pod):: kube.Service(name) {
    target_pod: target_pod,
  }
,
}
