#!/bin/bash

set -e

# Download the executable and the ISO
echo Downloading minikube components
if [[ ! -f minikube ]]; then
  URL=https://2020-08-17-cloud-native-bpf-workshop-public.s3.eu-central-1.amazonaws.com/minikube
  wget $URL
fi
if [[ ! -f minikube.iso ]]; then
  URL=https://2020-08-17-cloud-native-bpf-workshop-public.s3.eu-central-1.amazonaws.com/minikube.iso
  wget $URL
fi

# Verify that the sha256sums are correct
echo Verifying downloaded components
sha256sum -c <<EOF
8f2752174688bc7e0ced3cd63ed26ee51be2207df759f86775928f874defb4e2  minikube
645c7943a793d30d4d7ea34767a184741f8aece9860a22f9ba2d264825530dfc  minikube.iso
EOF

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
./minikube start --driver=kvm2 --iso-url=file://$(pwd)/minikube.iso
./minikube ssh -- 'bash -c "uname -a ; if [ -e /sys/kernel/kheaders.tar.xz ] ; then echo kheaders.tar.xz available ; else echo kheaders.tar.xz missing ; fi"'
