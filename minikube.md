# Minikube

During the Cloud Native BPF Workshop we'll use Minikube to show how to use
`kubectl-gadget` and `kubectl-trace`. Both these tools require having the
kernel headers accessible to be able to inject the BPF tracing calls.

If you're going to run Minikube in your local machine, we strongly
recommend that you run our specially created branch, which already includes
the kernel headers.

If you're going to run Minikube inside a VM, you can run the upstream version,
but you need to take care of installing the headers.  See below for
instructions.

## Running Minikube in your local machine.

We will be using this forked branch of Minikube:
[alban/bpf-workshop](https://github.com/kinvolk/minikube/tree/alban/bpf-workshop).
You can either install the pre-built image or build it from source
yourself.

### Our branch

It is based on [Minikube v1.12.0-beta.1](https://github.com/kubernetes/minikube/releases/tag/v1.12.0-beta.1) with the following changes:

- Based on Linux 5.4.40 (without the revert to Linux 4.19.107 from [#8649](https://github.com/kubernetes/minikube/pull/8649))
- Add `CONFIG_IKHEADERS` ([#8556](https://github.com/kubernetes/minikube/issues/8556))
- Fix podman checksum ([#8700](https://github.com/kubernetes/minikube/issues/8700))
- Add `CONFIG_FTRACE_SYSCALLS` ([#8637](https://github.com/kubernetes/minikube/issues/8637))

### Installing the pre-built image

This step should take around 10 minutes to complete.

For convenience, we've already built a Minikube command and ISO from our
branch. You can download and run them, with these commands:

```
mkdir bpf-workshop; cd bpf-workshop
wget https://eleven.dev.kinvolk.io/u/alban/cloud-native-bpf-workshop/minikube
wget https://eleven.dev.kinvolk.io/u/alban/cloud-native-bpf-workshop/minikube.iso
chmod +x minikube
./minikube delete
./minikube start --driver=kvm2 --iso-url=file://$(pwd)/minikube.iso
```

The last command will do all the necessary steps to create a Minikube
cluster (download Kubernetes, create the VM, run Kubernetes in the
cluster, etc).

This might fail if you don't have KVM setup on your machine. You can find
pointers to the documentation for how to set this up for different Linux
distributions at:
<https://minikube.sigs.k8s.io/docs/reference/drivers/kvm2/>

### Building the image from source

**Note**: This can take hours to complete so it's only recommended if
you're doing this well in advance.

If you would rather build the command and ISO yourself, you can check out
our branch and build from that source. This is how we built the published
version.

```
git clone https://github.com/kinvolk/minikube.git -b alban/bpf-workshop --single-branch
cd minikube
make
make out/minikube.iso
```

### Test Minikube

To verify that your minikube cluster is running the correct kernel with
kheaders.tar.xz and syscall tracing, you can run the following commands:

```
$ ./minikube ssh
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

## Using Minikube inside a virtual machine

Minikube doesn't support nested virtualization. It's possible to run it
inside a virtual machine with `--driver=docker`, but unfortunately
inspektor gadget doesn't support that.

So, if you intend to run this workshop inside a virtual machine (either a
local VM, or a VM in the cloud), you will need to use the `--driver=none`
parameter. This causes Minikube to use the local instance rather than a
container or a VM as the Kubernetes node.

In this case, you don't need to use our image, but **you'll need to take
care of installing the kernel headers for the OS that your VM is running**.

```
# This will start a Minikube cluster in the local machine
sudo ./minikube start --driver=none --apiserver-ips 127.0.0.1 --apiserver-name localhost

# This will back up any kubectl configuration, as it will then be overwritten
BACKDIR=$(mktemp -d -p $HOME kubecfg-backup-XXXX)
if [ -d $HOME/.kube ]; then mv $HOME/.kube ${BACKDIR}; fi
if [ -d $HOME/.minikube ]; then mv $HOME/.minikube ${BACKDIR}; fi

# This gets the generated kubectl configuration from the root directory
sudo mv /root/.kube /root/.minikube $HOME
sudo chown -R $USER $HOME/.kube $HOME/.minikube
sed -i "s,/root/,$HOME/," $HOME/.kube/config
```
