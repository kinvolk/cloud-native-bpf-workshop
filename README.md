# Cloud Native BPF Workshop

It's strongly recommended to have all requirements installed and ready to
use before starting the workshop.

## Minikube requirements

To try out the exercises of this workshop, you'll need to run a version of
Minikube with a few additional patches to get access to the kernel headers.
Please read [minikube.md](./minikube.md) for instructions.

## Inspektor Gadget requirements

During the workshop, we'll use release
[v0.2.0](https://github.com/kinvolk/inspektor-gadget/releases/tag/v0.2.0)
of Inspektor Gadget for all examples.

## kubectl-trace requirements

For the purpose of this workshop, we'll use a version of kubectl-trace with
patches that haven't been released yet. In particular, we'll use this
kubectl-trace branch
[alban/ikheaders](https://github.com/kinvolk/kubectl-trace/tree/alban/ikheaders)
that includes the following patches:
- https://github.com/iovisor/kubectl-trace/pull/123

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
