# nvidia-gpu

## Introduction

This chart manages the deployment of the required containers to install and
load the Nvidia GPU device drivers on a Kubernetes cluster.

## Prerequisites

- Kubernetes cluster, version >=1.9

## Installing the Chart

You can either clone the chart locally, or better add the cern repo to helm:
```
helm repo add cern https://registry.cern.ch/chartrepo/cern
helm repo update
```

To install the chart (you can change the namespace or release appropriately):
```bash
helm install --namespace=kube-system --name=nvidia-gpu cern/nvidia-gpu
```

You can override the defaults with an additional configuration file:
```bash
helm install --namespace=kube-system --name=nvidia-gpu cern/nvidia-gpu -f myconfig.yaml
```

By default the DaemonSet handling the driver will only install on nodes with
the `gpu=true` label. You can override this with the `nodeSelector` in values.

## Uninstalling the Chart

To uninstall / delete:
```bash
helm delete nvidia-gpu
```

To get rid of all the resources, use purge:
```bash
helm delete --purge nvidia-gpu
```
