# nvidia-gpu

## Introduction

This chart manages the deployment of the required containers to install and
load the Nvidia GPU device drivers on a Kubernetes cluster.

## Prerequisites

- Kubernetes cluster, version >=1.9

## Installing the Chart

To install the chart (you can change the namespace or release appropriately):

    helm install --namespace=kube-system nvidia-gpu ./

You can override the defaults with an additional configuration file:

    helm upgrade --install --namespace=kube-system nvidia-gpu ./ -f myconfig.yaml

By default the DaemonSet handling the driver will only install on nodes with
the `gpu=true` label. You can override this with the `nodeSelector` in values.

    kubectl label node <node-name> node-role.kubernetes.io/gpu=true

## Uninstalling the Chart

To uninstall / delete:

    helm delete nvidia-gpu

To get rid of all the resources, use purge:

    helm delete --purge nvidia-gpu
