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

## Magnum Nodegroup

Prior to installing helm chart, make sure that you add GPU flavor nodegroup to
your cluster. To create a GPU flavor nodegroup, add `--role gpu` flag:

    openstack coe nodegroup create k8s-cluster --flavor m1.gpu --role gpu gpu-worker

When the node is ready, the nodegroup should be visible:

    kubectl get nodes -L magnum.openstack.org/role
    NAME                                   STATUS   ROLES    AGE    VERSION   ROLE
    k8s-cluster-654l4zihkwov-master-0     Ready    master   151m   v1.20.6   master
    k8s-cluster-654l4zihkwov-node-0       Ready    <none>   147m   v1.20.6   worker
    k8s-cluster-gpu-worker-kwxqc-node-0   Ready    <none>   81s    v1.20.6   gpu

Additional information on nodegroups can be found at:
<https://docs.openstack.org/magnum/latest/user/#node-groups>.

## Helm Chart

To install the chart to `kube-system` namespace:

    make install

NOTE: The helm chart only installs drivers on nodegroups with
`magnum.openstack.org/role=gpu` label by default. Appropriate modifications
need to be made to `values.yml` for other scenarious.

## Test workflow

To test the usability of GPUs after deploying both daemonsets, there is a
CUDA sample pod that runs an nbody simulation. Check the results with:

    kubectl apply -f test/cuda-sample-nbody.yaml
    kubectl logs cuda-sample-nbody
