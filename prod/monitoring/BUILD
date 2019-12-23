
load("//jsonnet:yaml_to_json.bzl", "yaml_to_json")

SETUP = {
  "0namespace-namespace": "@monitoring//:manifests/setup/0namespace-namespace.yaml",
  "prometheus-operator-0prometheusCustomResourceDefinition": "@monitoring//:manifests/setup/prometheus-operator-0prometheusCustomResourceDefinition.yaml",
  "prometheus-operator-0podmonitorCustomResourceDefinition": "@monitoring//:manifests/setup/prometheus-operator-0podmonitorCustomResourceDefinition.yaml",
  "prometheus-operator-0prometheusruleCustomResourceDefinition": "@monitoring//:manifests/setup/prometheus-operator-0prometheusruleCustomResourceDefinition.yaml",
  "prometheus-operator-0servicemonitorCustomResourceDefinition": "@monitoring//:manifests/setup/prometheus-operator-0servicemonitorCustomResourceDefinition.yaml",
  "prometheus-operator-0alertmanagerCustomResourceDefinition": "@monitoring//:manifests/setup/prometheus-operator-0alertmanagerCustomResourceDefinition.yaml",
  "prometheus-operator-service": "@monitoring//:manifests/setup/prometheus-operator-service.yaml",
  "prometheus-operator-serviceAccount": "@monitoring//:manifests/setup/prometheus-operator-serviceAccount.yaml",
  "prometheus-operator-clusterRole": "@monitoring//:manifests/setup/prometheus-operator-clusterRole.yaml",
  "prometheus-operator-deployment": "@monitoring//:manifests/setup/prometheus-operator-deployment.yaml",
  "prometheus-operator-clusterRoleBinding": "@monitoring//:manifests/setup/prometheus-operator-clusterRoleBinding.yaml",
}

MAIN = {
  "prometheus-adapter-clusterRoleAggregatedMetricsReader": "@monitoring//:manifests/prometheus-adapter-clusterRoleAggregatedMetricsReader.yaml",
  "node-exporter-service": "@monitoring//:manifests/node-exporter-service.yaml",
  "kube-state-metrics-clusterRoleBinding": "@monitoring//:manifests/kube-state-metrics-clusterRoleBinding.yaml",
  "prometheus-operator-serviceMonitor": "@monitoring//:manifests/prometheus-operator-serviceMonitor.yaml",
  "alertmanager-serviceAccount": "@monitoring//:manifests/alertmanager-serviceAccount.yaml",
  "alertmanager-serviceMonitor": "@monitoring//:manifests/alertmanager-serviceMonitor.yaml",
  "prometheus-serviceMonitorKubeControllerManager": "@monitoring//:manifests/prometheus-serviceMonitorKubeControllerManager.yaml",
  "prometheus-adapter-clusterRole": "@monitoring//:manifests/prometheus-adapter-clusterRole.yaml",
  "node-exporter-daemonset": "@monitoring//:manifests/node-exporter-daemonset.yaml",
  "prometheus-adapter-clusterRoleServerResources": "@monitoring//:manifests/prometheus-adapter-clusterRoleServerResources.yaml",
  "prometheus-adapter-serviceAccount": "@monitoring//:manifests/prometheus-adapter-serviceAccount.yaml",
  "node-exporter-serviceMonitor": "@monitoring//:manifests/node-exporter-serviceMonitor.yaml",
  "grafana-serviceAccount": "@monitoring//:manifests/grafana-serviceAccount.yaml",
  "prometheus-serviceAccount": "@monitoring//:manifests/prometheus-serviceAccount.yaml",
  "prometheus-adapter-configMap": "@monitoring//:manifests/prometheus-adapter-configMap.yaml",
  "node-exporter-clusterRoleBinding": "@monitoring//:manifests/node-exporter-clusterRoleBinding.yaml",
  "prometheus-adapter-service": "@monitoring//:manifests/prometheus-adapter-service.yaml",
  "node-exporter-serviceAccount": "@monitoring//:manifests/node-exporter-serviceAccount.yaml",
  "kube-state-metrics-serviceMonitor": "@monitoring//:manifests/kube-state-metrics-serviceMonitor.yaml",
  "prometheus-service": "@monitoring//:manifests/prometheus-service.yaml",
  "grafana-dashboardDatasources": "@monitoring//:manifests/grafana-dashboardDatasources.yaml",
  "alertmanager-secret": "@monitoring//:manifests/alertmanager-secret.yaml",
  "prometheus-adapter-apiService": "@monitoring//:manifests/prometheus-adapter-apiService.yaml",
  "prometheus-adapter-deployment": "@monitoring//:manifests/prometheus-adapter-deployment.yaml",
  "prometheus-adapter-clusterRoleBindingDelegator": "@monitoring//:manifests/prometheus-adapter-clusterRoleBindingDelegator.yaml",
  "prometheus-roleSpecificNamespaces": "@monitoring//:manifests/prometheus-roleSpecificNamespaces.yaml",
  "kube-state-metrics-service": "@monitoring//:manifests/kube-state-metrics-service.yaml",
  "prometheus-clusterRoleBinding": "@monitoring//:manifests/prometheus-clusterRoleBinding.yaml",
  "prometheus-serviceMonitorKubelet": "@monitoring//:manifests/prometheus-serviceMonitorKubelet.yaml",
  "kube-state-metrics-roleBinding": "@monitoring//:manifests/kube-state-metrics-roleBinding.yaml",
  "prometheus-adapter-clusterRoleBinding": "@monitoring//:manifests/prometheus-adapter-clusterRoleBinding.yaml",
  "prometheus-prometheus": "@monitoring//:manifests/prometheus-prometheus.yaml",
  "kube-state-metrics-deployment": "@monitoring//:manifests/kube-state-metrics-deployment.yaml",
  "prometheus-rules": "@monitoring//:manifests/prometheus-rules.yaml",
  "node-exporter-clusterRole": "@monitoring//:manifests/node-exporter-clusterRole.yaml",
  "prometheus-clusterRole": "@monitoring//:manifests/prometheus-clusterRole.yaml",
  "alertmanager-service": "@monitoring//:manifests/alertmanager-service.yaml",
  "prometheus-serviceMonitorKubeScheduler": "@monitoring//:manifests/prometheus-serviceMonitorKubeScheduler.yaml",
  "grafana-serviceMonitor": "@monitoring//:manifests/grafana-serviceMonitor.yaml",
  "grafana-dashboardSources": "@monitoring//:manifests/grafana-dashboardSources.yaml",
  "prometheus-serviceMonitorApiserver": "@monitoring//:manifests/prometheus-serviceMonitorApiserver.yaml",
  "prometheus-roleConfig": "@monitoring//:manifests/prometheus-roleConfig.yaml",
  "kube-state-metrics-serviceAccount": "@monitoring//:manifests/kube-state-metrics-serviceAccount.yaml",
  "grafana-service": "@monitoring//:manifests/grafana-service.yaml",
  "prometheus-serviceMonitorCoreDNS": "@monitoring//:manifests/prometheus-serviceMonitorCoreDNS.yaml",
  "grafana-dashboardDefinitions": "@monitoring//:manifests/grafana-dashboardDefinitions.yaml",
  "alertmanager-alertmanager": "@monitoring//:manifests/alertmanager-alertmanager.yaml",
  "grafana-deployment": "@monitoring//:manifests/grafana-deployment.yaml",
  "prometheus-adapter-roleBindingAuthReader": "@monitoring//:manifests/prometheus-adapter-roleBindingAuthReader.yaml",
  "prometheus-serviceMonitor": "@monitoring//:manifests/prometheus-serviceMonitor.yaml",
  "prometheus-roleBindingConfig": "@monitoring//:manifests/prometheus-roleBindingConfig.yaml",
  "prometheus-roleBindingSpecificNamespaces": "@monitoring//:manifests/prometheus-roleBindingSpecificNamespaces.yaml",
  "kube-state-metrics-role": "@monitoring//:manifests/kube-state-metrics-role.yaml",
  "kube-state-metrics-clusterRole": "@monitoring//:manifests/kube-state-metrics-clusterRole.yaml",
}

[yaml_to_json(
    name = name,
    src = target,
) for name, target in SETUP.items()]

[yaml_to_json(
    name = name,
    src = target,
) for name, target in MAIN.items()]

load("@io_bazel_rules_jsonnet//jsonnet:jsonnet.bzl", "jsonnet_to_json")

jsonnet_to_json(
    name = "setup",
    src = "setup.jsonnet",
    outs = [name + "-patched.json" for name in SETUP],
    multiple_outputs = 1,
    ext_code = {"names": "%s" % SETUP.keys()},
    ext_code_file_vars = SETUP.keys(),
    ext_code_files = [name + ".json" for name in SETUP],
)
jsonnet_to_json(
    name = "main",
    src = "main.jsonnet",
    outs = [name + "-patched.json" for name in MAIN],
    multiple_outputs = 1,
    ext_code = {"names": "%s" % MAIN.keys()},
    ext_code_file_vars = MAIN.keys(),
    ext_code_files = [name + ".json" for name in MAIN],
)

load("@k8s_object//:defaults.bzl", "k8s_object")


[k8s_object(
    name = name + "_k8s",
    template = ":%s-patched.json" % name,
) for name in SETUP.keys()]

[k8s_object(
    name = name + "_k8s",
    template = ":%s-patched.json" % name,
) for name in MAIN.keys()]

load("@io_bazel_rules_k8s//k8s:objects.bzl", "k8s_objects")

k8s_objects(
    name = "monitoring-setup",
    objects = ["%s_k8s" % name for name in SETUP.keys()]
)
k8s_objects(
    name = "monitoring",
    objects = ["%s_k8s" % name for name in MAIN.keys()]
)