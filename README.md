# nvidia-driver-container

The nvidia-driver-installer container for Fedora CoreOS is built from this repo
and available at: <https://ghcr.io/stackhpc/nvidia-driver-installer>.

It installs the nvidia driver in the container with the official nvidia
installer, including kmods and libs. Some pieces are omitted, including 32bit
compatibility libraries and the drm kmod (graphics).

It then copies over the installation to a 2nd stage (no kmod build deps).
When this is run on a minion, it will load the nvidia kmods, make the nvidia
device files and copy the driver bins and libs to a place on the host that
the k8s device plugin knows.

The k8s nvidia device plugin is fetched from upstream google; its daemonset
is slightly modified, because the upstream is made for GCP.

## Caveat

At present, the driver requires SELinux to be turned off on workers with GPUs.
Magnum has a built in support for `selinux_mode` label which can be set to
`permissive`.

## Image

Build and push the image:

    make build
    make push

## Helm Chart

To install the chart (you can change the namespace or release appropriately):

    helm install --namespace=kube-system --name=nvidia-gpu ./chart/

You can override the defaults with an additional configuration file:

    helm install --namespace=kube-system --name=nvidia-gpu ./chart/ -f myconfig.yaml

By default the DaemonSet handling the driver will only install on nodes with
the `gpu=true` label. You can override this with the `nodeSelector` in values.

    kubectl label node <node-name> node-role.kubernetes.io/gpu=true

## Test workflow

To test the usability of GPUs after deploying both daemonsets, there is a
CUDA sample pod that runs an nbody simulation. Check the results with:

    kubectl apply -f test/cuda-sample-nbody.yaml
    kubectl logs cuda-sample-nbody
