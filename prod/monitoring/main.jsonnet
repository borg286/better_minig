local files = {
	[name + "-patched.json"]: std.extVar(name) for name in  std.extVar("names")
};


local override_panel1(panels, idx, extra_env) = (
  local f(i, x) = (
    if i == idx then x +{targets:[
      if target.refId == "A" then target{expr: "sum by(container) (container_memory_working_set_bytes{job=\"kubelet\", cluster=\"$cluster\", namespace=\"$namespace\", pod=\"$pod\"})"}
      else if target.refId == "B" then target{expr: "sum by(container) (kube_pod_container_resource_requests{job=\"kube-state-metrics\", cluster=\"$cluster\", namespace=\"$namespace\", resource=\"memory\", pod=\"$pod\"})"}
      else if target.refId == "C" then target{expr: "sum by(container) (kube_pod_container_resource_limits{job=\"kube-state-metrics\", cluster=\"$cluster\", namespace=\"$namespace\", resource=\"memory\", pod=\"$pod\"})"}
      else if target.refId == "D" then target{expr: "sum by(container) (container_memory_cache{job=\"kubelet\", cluster=\"$cluster\", namespace=\"$namespace\", pod=~\"$pod\"})"}
      else target
      for target in super.targets
    ]} else x
  );
  std.mapWithIndex(f, panels)
);
local override_panel2(panels, idx, extra_env) = (
  local f(i, x) = (
    if i == idx then x +{targets:[
           if target.refId == "A" then target{expr: "sum by(container) (irate(container_cpu_usage_seconds_total{job=\"kubelet\", cluster=\"$cluster\", namespace=\"$namespace\", pod=\"$pod\"}[4m]))"}
      else if target.refId == "B" then target{expr: "sum by(container) (kube_pod_container_resource_requests{job=\"kube-state-metrics\", cluster=\"$cluster\", namespace=\"$namespace\", resource=\"cpu\", pod=\"$pod\"})"}
      else if target.refId == "C" then target{expr: "sum by(container) (kube_pod_container_resource_limits{job=\"kube-state-metrics\", cluster=\"$cluster\", namespace=\"$namespace\", resource=\"cpu\", pod=\"$pod\"})"}
      else target
      for target in super.targets
    ]} else x
  );
  std.mapWithIndex(f, panels)
);

local override_row(rows) = (
  local f(i, x) = (
    if i == 0 then x {panels:override_panel1(super.panels, 0, {})}
    else if i == 1 then x {panels:override_panel2(super.panels, 0, {})}
    else x
  );
  std.mapWithIndex(f, rows)
);

local pod_dashboard = std.parseJson(std.filter(function (x) std.objectHas(x.data, "pods.json"), files["grafana-dashboardDefinitions-patched.json"].items)[0].data["pods.json"]);
local new_dashboard = pod_dashboard +{rows: override_row(super.rows)};

local unpatched = files + {
        ["grafana-deployment-patched.json"] +:{spec +:{template +:{spec +:{containers:[
            if container.name == "grafana" then container + {env +:[
              {name: "GF_AUTH_BASIC_ENABLED",value : "false"},
              {name: "GF_AUTH_ANONYMOUS_ENABLED",value : "true"},
              {name: "GF_AUTH_ANONYMOUS_ORG_ROLE",value : "Admin"},
              {name: "GF_SERVER_ROOT_URL",value : "/"},
            ]}
            else container
            for container in super.containers
        ]}}}}
};

local patched = unpatched + {
    ["prometheus-rules-patched.json"] +: {spec+:{groups: [
        if group.name == "k8s.rules" then group  +{rules: [
            if rule.record == "namespace:container_cpu_usage_seconds_total:sum_rate" then rule +{
                expr : 'sum(rate(container_cpu_usage_seconds_total{job="kubelet"}[5m])) by (namespace)'
            }
            else if rule.record == "node_namespace_pod_container:container_cpu_usage_seconds_total:sum_rate" then rule +{
                expr : 'rate(container_cpu_usage_seconds_total{job="kubelet"}[5m])'
            }
            else if rule.record == "node_namespace_pod_container:container_memory_working_set_bytes" then rule +{
                expr : 'container_memory_working_set_bytes{job="kubelet"} * on (namespace, pod) group_left(node) max by(namespace, pod, node) (kube_pod_info)'
            }
            else if rule.record == "node_namespace_pod_container:container_memory_rss" then rule +{
                expr : 'container_memory_rss{job="kubelet"} * on (namespace, pod) group_left(node) max by(namespace, pod, node) (kube_pod_info)'
            }
            else if rule.record == "node_namespace_pod_container:container_memory_cache" then rule +{
                expr : 'container_memory_cache{job="kubelet"} * on (namespace, pod) group_left(node) max by(namespace, pod, node) (kube_pod_info)'
            }
            else if rule.record == "node_namespace_pod_container:container_memory_swap" then rule +{
                expr : 'container_memory_swap{job="kubelet"} * on (namespace, pod) group_left(node) max by(namespace, pod, node) (kube_pod_info)'
            }
            else rule
            for rule in super.rules
        ]}
        else group
        for group in super.groups
    ]}}
} + {
	["grafana-dashboardDefinitions-patched.json"] +: {items:[
	    if std.objectHas(item.data, "pods.json") then item +{data: {"pods.json": std.manifestJson(new_dashboard)}}
	    else item
	    for item in super.items
	]}
};


unpatched
