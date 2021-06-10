#!/bin/bash

set -e

# Download the executable and the ISO
echo Downloading minikube components
if [[ ! -f minikube ]]; then
  URL=https://cloud-native-bpf-workshop-public.s3.eu-central-1.amazonaws.com/minikube
  wget $URL
fi
if [[ ! -f minikube.iso ]]; then
  URL=https://cloud-native-bpf-workshop-public.s3.eu-central-1.amazonaws.com/minikube.iso
  wget $URL
fi

# Verify that the sha256sums are correct
echo Verifying downloaded components
sha256sum -c <<EOF
8f2752174688bc7e0ced3cd63ed26ee51be2207df759f86775928f874defb4e2  minikube
645c7943a793d30d4d7ea34767a184741f8aece9860a22f9ba2d264825530dfc  minikube.iso
EOF

# If user is not in group libvirt, minikube will fail due to lack of permissions
if id -Gn | grep -qvw libvirt ; then
  echo "User '`id -un`' not in group libvirt. Probably, groups have not been updated yet on current shell."
  echo "Suggestion: run 'newgrp libvirt'"
  exit 1
fi

echo This script will delete the existing minikube VM if you have one, and
echo start a new one.
read -p "Are you sure? [yes/no] " -r

if [[ ! $REPLY =~ ^yes$ ]]; then
  echo Abort.
  exit 1
fi

echo Executing minikube
chmod +x minikube
./minikube delete

if [ "$1" == "--use-driver-none" ]; then
  echo "Starting minikube as root with the none driver, as requested"
  sudo ./minikube start --driver=none --iso-url=file://$(pwd)/minikube.iso --apiserver-ips 127.0.0.1 --apiserver-name localhost
  BACKDIR=$(mktemp -d -p $HOME kubecfg-backup-XXXX)
  echo "Backing up existing kubectl configuration in ${BACKDIR}"
  if [ -d $HOME/.kube ]; then mv $HOME/.kube ${BACKDIR}; fi
  if [ -d $HOME/.minikube ]; then mv $HOME/.minikube ${BACKDIR}; fi
  echo "Getting kubectl configuration from the root directory"
  sudo mv /root/.kube /root/.minikube $HOME
  sudo chown -R $USER $HOME/.kube $HOME/.minikube
  sed -i "s,/root/,$HOME/," $HOME/.kube/config
else
  ./minikube start --driver=kvm2 --iso-url=file://$(pwd)/minikube.iso
  echo Verifying that kernel headers are correctly installed in minikube
  ./minikube ssh -- 'bash -c "uname -a ; if [ -e /sys/kernel/kheaders.tar.xz ] ; then echo kheaders.tar.xz available ; else echo kheaders.tar.xz missing ; fi"'
fi
