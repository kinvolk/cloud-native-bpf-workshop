#!/bin/bash

set -e

# Download the executable and the ISO
echo Downloading minikube components
if [[ ! -f minikube ]]; then
  wget https://eleven.dev.kinvolk.io/u/alban/cloud-native-bpf-workshop/minikube
fi
if [[ ! -f minikube.iso ]]; then
  wget https://eleven.dev.kinvolk.io/u/alban/cloud-native-bpf-workshop/minikube.iso
fi

# Verify that the sha256sums are correct
echo Verifying downloaded components
sha256sum -c <<EOF
8f2752174688bc7e0ced3cd63ed26ee51be2207df759f86775928f874defb4e2  minikube
645c7943a793d30d4d7ea34767a184741f8aece9860a22f9ba2d264825530dfc  minikube.iso
EOF

echo Executing minikube
chmod +x minikube
./minikube delete
./minikube start --driver=kvm2 --iso-url=file://$(pwd)/minikube.iso
