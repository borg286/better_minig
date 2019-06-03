local kube = import 'external/kube_jsonnet/kube.libsonnet';

{
  Server(name, namespace):: kube.StatefulSet(name) {
    metadata+:{namespace: namespace},
    spec+: {
      replicas: 1,
      template+: {spec+: {containers_+: {
        gb_fe: kube.Container("redis") {
          image: "redis",
          resources: {},
          args: [],
          ports_+: { tcp: { containerPort: 6379 } },
          readinessProbe:{
            exec:{command:[
              "sh", "-c", "timeout -t 1 redis-cli -h $(hostname) cluster info | grep 'cluster_state:ok'"
            ]},
            initialDelaySeconds: 1,
            timeoutSeconds: 5
          },
          livenessProbe:{
            exec:{command:[
              "sh", "-c", "timeout -t 1 redis-cli -h $(hostname) info"
            ]},
            initialDelaySeconds: 1,
            periodSeconds: 3,
          }
    }}}}}
  },
  Service(name, target_pod, namespace):: kube.Service(name) {
    metadata+:{namespace: namespace},
    target_pod: target_pod,
  }
,
}
