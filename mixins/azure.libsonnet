local kubernetes = import 'github.com/kubernetes-monitoring/kubernetes-mixin/mixin.libsonnet';

kubernetes {
  _config+:: {
    cadvisorSelector: 'job="cadvisor"',
    kubeApiserverSelector: 'job="kube-apiserver"',
    kubeControllerManagerSelector: 'job="kube-controller-manager"',
    kubeletSelector: 'job="kubelet"',
    kubeProxySelector: 'job=~"kube-proxy|kube-proxy-windows"',
    kubeSchedulerSelector: 'job="kube-scheduler"',
    kubeStateMetricsSelector: 'job="kube-state-metrics"',
    nodeExporterSelector: 'job="node"',
    windowsExporterSelector: 'job="windows-exporter"',

    showMultiCluster: true,
  },
}
