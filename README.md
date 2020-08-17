# Cloud Native BPF Workshop

It's strongly recommended to have all requirements installed and ready to
use before starting the workshop. This could be on your own computer or on
a virtual machine that you have access to.

## Minikube requirements

To try out the exercises of this workshop, you'll need to run a version of
Minikube with a few additional patches to get access to the kernel headers.
Please read [minikube.md](./minikube.md) for instructions.

## kubectl requirements

Please make sure that the machine you're using has kubectl installed. You
can refer to [this
page](https://kubernetes.io/docs/tasks/tools/install-kubectl/) for
installation instructions.

## Inspektor Gadget requirements

During the workshop, we'll use release
[v0.2.0](https://github.com/kinvolk/inspektor-gadget/releases/tag/v0.2.0)
of Inspektor Gadget for all examples. Please follow the [installation
instructions](https://github.com/kinvolk/inspektor-gadget/blob/master/Documentation/install.md),
to have this ready.

## kubectl-trace requirements

During the workshop, we'll also use kubectl-trace. Please follow the
[installation
instructions](https://github.com/iovisor/kubectl-trace#installing) for
installing the plugin on your computer.

kubectl-trace is a client-side plugin but it starts pods in the Kubernetes cluster named "trace-runner".
We needed changes on the trace-runner pod. We'll use a version of kubectl-trace with
patches that haven't been released yet, so that it can work inside Minikube.
In particular, we'll use this kubectl-trace branch
[alban/ikheaders](https://github.com/kinvolk/kubectl-trace/tree/alban/ikheaders)
that includes the following patch:
- https://github.com/iovisor/kubectl-trace/pull/123 - add xz-utils to the
  container image

For convenience, there is a build with container images available on Docker registries.
```
$ kubectl trace run \
    --imagename "docker.io/albanc/kubectl-trace-bpftrace:e896345e3d8f80aa968422c6199ac5180d688f65" \
    --init-imagename "docker.io/albanc/kubectl-trace-init:e896345e3d8f80aa968422c6199ac5180d688f65" \
    minikube -e "tracepoint:syscalls:sys_enter_* { @[probe] = count(); }"
$ kubectl trace get
$ kubectl trace attach kubectl-trace-a05bde1e-c44a-11ea-b314-c85b763781a4
```

It was built with the following commands
```
$ export IMAGE_NAME_INIT=docker.io/albanc/kubectl-trace-init
$ export IMAGE_NAME=docker.io/albanc/kubectl-trace-bpftrace
$ make build
$ make build image/build-init image/build
$ make image/push
```

# Workshop Material

During the workshop, we will cover the basics of BPF and we will go through
the exercises listed here, in order.

Please join the slack channel `#2-kubecon-tutorials-bpf` in the CNCF Slack.
Feel free to ask questions and discuss with your fellow attendees.

You can refer to the [slides](slides.pdf) at any time.
