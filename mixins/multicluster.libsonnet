local kubernetes = import 'github.com/kubernetes-monitoring/kubernetes-mixin/mixin.libsonnet';

kubernetes {
  _config+:: {
    showMultiCluster: true,
  },
}
