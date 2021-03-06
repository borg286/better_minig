
local kube = import 'external/kube_jsonnet/kube.libsonnet';
local util = import 'jsonnet/utils.libsonnet';
local params = std.extVar("params");
local name = params.name;

local image = params.local_image_name;

local redis_conf = '
appendfilename "appendonly.aof"
daemonize no
protected-mode no
rdbchecksum yes
syslog-enabled no
syslog-facility local0
tcp-backlog 2048
cluster-enabled yes
dbfilename dump.rdb
dir /data
';

local start = '
cp /conf/redis.conf /tmp/redis.conf
echo "cluster-announce-ip $POD_IP" >> /tmp/redis.conf
redis-server /tmp/redis.conf
';

local redis = {
  redis_container: kube.Container("redis") {
    image: "redis",
    resources: {},
    ports_+: { 
      tcp: { containerPort: 6379 },
      gossip: {containerPort: 16379},
    },
    command: ["/bin/bash"],
    args: ["-c", start],
    readinessProbe:{
      exec:{command:[
        "sh", "-c", "timeout 1 redis-cli -h $(hostname) cluster info | grep 'cluster_state:ok'",
      ]},
      initialDelaySeconds: 1,
      timeoutSeconds: 5
    },
    livenessProbe:{
      exec:{command:[
        "sh", "-c", "timeout 1 redis-cli -h $(hostname) ping"
      ]},
      initialDelaySeconds: 1,
      periodSeconds: 3,
    },
    env_: {
      POD_NAME: kube.FieldRef("metadata.name"),
      POD_NAMESPACE: kube.FieldRef("metadata.namespace"),
      POD_IP: kube.FieldRef("status.podIP"),
      BASE: name,
    },
    volumeMounts_+: {
      config_vol: {mountPath: "/conf"},
      shared_vol: {mountPath: "/share"},
      name: {mountPath: "/data"},    
    }
  },
  prestart: kube.Container("prestart") {
    image: image,
    args: ["prestart"],
    env_: {
      POD_NAME: kube.FieldRef("metadata.name"),
      POD_NAMESPACE: kube.FieldRef("metadata.namespace"),
      BASE: name,
      POD_IP: kube.FieldRef("status.podIP"),
    },
    volumeMounts_+: {
      name: {mountPath: "/data"},
    },
  },
  sidecar: kube.Container("sidecar") {
    image: image,
    args: ["sidecar"],
    resources: {},
    ports_+: { tcp: { containerPort: 8080 } },
    env_: {
      POD_NAME: kube.FieldRef("metadata.name"),
      POD_NAMESPACE: kube.FieldRef("metadata.namespace"),
      BASE: name,
      POD_IP: kube.FieldRef("status.podIP"),
    },
    volumeMounts_+: {
      shared_vol: {mountPath: "/share"},
      name: {mountPath: "/data"},
    },
  },
  statefulset: kube.StatefulSet(name) {
    spec+: {
      replicas: 6,
      template+: {
        spec+: {
          default_container: "redis",
          initContainers_: {
            "prestart": $.prestart,
          },
          containers_+: {
            "sidecar": $.sidecar,
            "redis": $.redis_container,
          },
          volumes_+: {
            config_vol: kube.ConfigMapVolume($.redis_conf_map),
            shared_vol: kube.EmptyDirVolume(),
          },
        },
      },
      volumeClaimTemplates_+: {
        name: {
          storage: "1Gi",
          spec+: {storageClassName: "local-path"}
        },
      },
    },
  },
  redis_conf_map: kube.ConfigMap("redis-conf") {
    data: {
      "redis.conf": redis_conf,
    },
  },
  service: kube.Service(name) {
    // Make this a headless service so DNS lookups return pod IPs
    spec +:{clusterIP:'None'},
    target_pod: $.statefulset.spec.template,
  },
};

local main_name = name + "-statefulset.json";
local service_name = name + "-svc.json";
local redis_conf_name = name + "-conf.json";

{
  [main_name]: redis.statefulset,
  [service_name]: redis.service,
  [redis_conf_name]: redis.redis_conf_map,
}
