# monitoring-mixin

Rendered mixins for Grafana and Prometheus.

## Overview

This repository contains a set of rendered Jsonnet mixins for:

- Grafana Dashboards
- Prometheus Alert Rules
- Prometheus Recording Rules

All Prometheus rules are normalized, validated, and saved in YAML and JSON formats.

## Configurations

[kubernetes-mixin](https://github.com/kubernetes-monitoring/kubernetes-mixin):

- **azure** - compatible with Azure Managed Prometheus
- **default** - without custom configurations
- **multicluster** - enabled multicluster option

## Usage

All ready-to-use files are available under the [docs/](docs) directory of this repository.

### Dashboards

Example configuration for [Grafana Helm Chart](https://github.com/grafana/helm-charts):

```yaml
dashboardProviders:
  dashboardproviders.yaml:
    apiVersion: 1
    providers:
      - name: kubernetes
        folder: Kubernetes
        options:
          path: /var/lib/grafana/dashboards/kubernetes

dashboards:
  kubernetes:
    k8s-resources-cluster:
      url: https://raw.githubusercontent.com/bonddim/monitoring-mixin/main/docs/azure/dashboards/k8s-resources-cluster.json
    k8s-resources-namespace:
      url: https://raw.githubusercontent.com/bonddim/monitoring-mixin/main/docs/azure/dashboards/k8s-resources-namespace.json
    k8s-resources-node:
      url: https://raw.githubusercontent.com/bonddim/monitoring-mixin/main/docs/azure/dashboards/k8s-resources-node.json
    k8s-resources-pod:
      url: https://raw.githubusercontent.com/bonddim/monitoring-mixin/main/docs/azure/dashboards/k8s-resources-pod.json
    k8s-resources-workload:
      url: https://raw.githubusercontent.com/bonddim/monitoring-mixin/main/docs/azure/dashboards/k8s-resources-workload.json
```

### Prometheus Rules

- **YAML** files for Prometheus instance config
- **JSON** are easier to use in automation scripts

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.
