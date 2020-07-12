# Minikube

The Cloud Native BPF Workshop uses this branch of Minikube: [alban/bpf-workshop](https://github.com/kinvolk/minikube/tree/alban/bpf-workshop).

## Our branch

It is based on [Minikube v1.12.0-beta.1](https://github.com/kubernetes/minikube/releases/tag/v1.12.0-beta.1) with the following changes:

- Based on Linux 5.4.40 (without the revert to Linux 4.19.107 from [#8649](https://github.com/kubernetes/minikube/pull/8649))
- Add `CONFIG_IKHEADERS` ([#8556](https://github.com/kubernetes/minikube/issues/8556))
- Fix podman checksum ([#8700](https://github.com/kubernetes/minikube/issues/8700))
- Add `CONFIG_FTRACE_SYSCALLS` ([#8637](https://github.com/kubernetes/minikube/issues/8637))

## Installation

```
$ wget https://eleven.dev.kinvolk.io/u/alban/cloud-native-bpf-workshop/minikube
$ wget https://eleven.dev.kinvolk.io/u/alban/cloud-native-bpf-workshop/minikube.iso
$ ./minikube delete
$ ./minikube start --driver=kvm2 --iso-url=file://$(pwd)/minikube.iso
```

## How it was compiled

```
$ make
$ make out/minikube.iso
$ scp out/minikube* eleven.dev.kinvolk.io:/var/www/u/alban/cloud-native-bpf-workshop/
```

## Test Minikube

Check you have the correct kernel with kheaders.tar.xz and syscall tracing:

```
$ minikube ssh
$ uname -r
5.4.40
$ uname -a
Linux minikube 5.4.40 #2 SMP Sun Jul 12 13:26:21 UTC 2020 x86_64 GNU/Linux
$ ls -l /sys/kernel/kheaders.tar.xz
-r--r--r-- 1 root root 3436428 Jul 12 14:01 /sys/kernel/kheaders.tar.xz
$ sudo ls -l /sys/kernel/debug/tracing/events/syscalls/sys_enter_openat/id
-r--r--r-- 1 root root 0 Jul 12 14:00 /sys/kernel/debug/tracing/events/syscalls/sys_enter_openat/id
$
```
