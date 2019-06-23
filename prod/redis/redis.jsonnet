
local kube = import 'external/kube_jsonnet/kube.libsonnet';
local envs = import 'prod/envs.libsonnet';
local params = std.extVar("params");
local name = params.name;
local namespace = params.env;

local bootstrap_script = "redis-server";

local redis = {
  redis_container: kube.Container("redis") {
    image: "redis",
    resources: {},
    args: [],
    ports_+: { tcp: { containerPort: 6379 } },
    readinessProbe:{
      exec:{command:[
        "sh", "-c",
        "exit 0; info=$(timeout 1 redis-cli -h $(hostname) cluster info);
          if [ $? -gt 0 ]; then
            exit 1
          fi
          size=$(echo $info | grep 'cluster_size:' | cut -d: -f 2)
          echo $info | grep 'cluster_state:ok' && [ $size -gt 2 ]
         ",
      ]},
      initialDelaySeconds: 1,
      timeoutSeconds: 5
    },
    livenessProbe:{
      exec:{command:[
        "sh", "-c", "timeout 1 redis-cli -h $(hostname) info"
      ]},
      initialDelaySeconds: 1,
      periodSeconds: 3,
    },
    env_: {
      POD_NAME: kube.FieldRef("metadata.name"),
      SERVICE_NAME: name,
    },
  },
  statefulset: kube.StatefulSet(name) {
    metadata+:{namespace: envs.getName(params.env)},
    spec+: {
      replicas: 1,
      template+: {
        spec+: {
          containers_+: {
            "redis": $.redis_container,
          },
           volumes_+: {
            conf_vol: kube.ConfigMapVolume($.config_map),
          },
        },
      },
    },
  },
  config_map: kube.ConfigMap("bootstrap") {
    metadata+:{namespace: envs.getName(params.env)},
    data: {
      "bootstrap.sh": bootstrap_script
    }
  },
  service: kube.Service(name) {
    metadata+:{namespace: envs.getName(params.env)},
    target_pod: $.statefulset.spec.template,
  },
};

local main_name = name + "-" + namespace + "-statefulset.json";
local config_map_name = name + "-" + namespace + "-config-map.json";
local service_name = name + "-" + namespace + "-svc.json";

{
  [main_name]: redis.statefulset,
  [config_map_name] : redis.config_map,
  [service_name]: redis.service,
  
}
