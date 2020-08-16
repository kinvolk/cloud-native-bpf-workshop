## Setting up an Ubuntu or Debian machine from scratch

To be able to run minikube on your machine you might need certain packages
and permissions. Things like docker and KVM need to already be set up.

In particular, on a freshly installed Ubuntu or Debian machine, these
commands are needed.

```
sudo apt-get update
sudo apt-get install docker.io

sudo apt-get install qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils
sudo adduser `id -un` libvirt

curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
```

For convenience, you can run the `ubuntu-deps.sh` script in this directory
which contains these commands.

### Setting up an Ubuntu VM for running a nested Minikube

It's possible to run Minikube inside a VM using the `none` driver. In that
case, you'll need to make sure that you have `conntrack` installed and that
you enable docker and to allow unrestricted writing to regular files.

```
sudo apt-get install conntrack

sudo systemctl enable docker.service
sudo sysctl fs.protected_regular=0
```

For convenience, you can run the `ubuntu-vm-deps.sh` script in this
directory which will do this for you.
