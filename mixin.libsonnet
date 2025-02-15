local kubernetes = import "upstream-mixin.libsonnet";

// https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master#customising-the-mixin
// TODO when we want to exclude/ignore stuff this could help: https://github.com/nabadger/monitoring-mixins
// https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master#customising-alert-annotations

kubernetes {
  _config+:: {
    cadvisorSelector: 'job="kubelet", metrics_path="/metrics/cadvisor"',
    kubeApiserverSelector: 'job="apiserver"',
    kubeSchedulerSelector: 'job="apiserver"',
    // KubeControllerManagerDown alert disabled by Yolean/kubernetes-assert; is there a better way than to negate the selector?
    kubeControllerManagerSelector: 'job!="kube-controller-manager"',
    kubeStateMetricsSelector: 'job="kube-state-metrics"',
    nodeExporterSelector: 'job="node-exporter"',
    kubeletSelector: 'job="kubelet"',
    cpuThrottlingSelector: 'pod!~"metrics-server.*"',
  },
}