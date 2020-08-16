## 00 - Getting Started

Before we get started with the exercises, we need to have all the elements
in place. This directory has a couple of scripts to help you get quickly
set up.

This assumes that your machine has the necessary packages for using libvirt
already installed, that your user has the right permissions and that you
already have kubectl installed.  [Instructions on how to get there on
Ubuntu or Debian](ubuntu.md)

## Creating a Minikube cluster

Install and run minikube by running `./start_minikube.sh`.  This will set
up a minikube instance as described in our [instructions](../minikube.md).
If it works fine, you'll have a cluster ready to use once the script is
done. If there are errors, check the documentation.

You can check that your cluster is running correctly by running `kubectl
get pods -A` and verifying that you have the usual cluster management pods.

**Note**: Minikube doesn't support nested virtualization, so if you want to
run minikube inside a VM, you can do this by passing `--use-driver-none` to
the `./start_minikube.sh` script. This will use the current instance as the
node and is only recommended for a disposable VM. You will need to install
the kernel headers for the current OS. If running Ubuntu or Debian, you'll
also need to install the `conntrack` package if it's not installed and
possibly change some settings, depending on the specific version you're
running.

## Adding the Inspektor Gadget plugin

Install Inspektor Gadget by running `./get_inspektor_gadget`. This will
download and install `kubectl-gadget` either by using krew, if you have it
enabled, or by downloading it and copying it to the same path as `kubectl`.
If there are any errors, check the Inspektor Gadget [installation
docs](https://github.com/kinvolk/inspektor-gadget/blob/master/Documentation/install.md).

You can check that it's working correctly by running `kubectl gadget help`.

## Adding the gadget pod to the cluster

Once you have the cluster running and the gadget plugin installed, you can
add the gadget pod to your cluster by running:

```
kubectl gadget deploy | kubectl apply -f -
```

And then check that the pod was deployed and is working correctly with:

```
kubectl get pod -n kube-system
kubectl logs -n kube-system -l k8s-app=gadget --tail=-1 | head -19
```

