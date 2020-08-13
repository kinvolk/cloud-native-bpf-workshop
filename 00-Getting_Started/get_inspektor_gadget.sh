#!/bin/bash

# Check that kubectl is installed
if ! kubectl version --client=true >/dev/null 2>&1; then
  echo "ERROR: Can't execute kubectl."
  echo "Make sure kubectl is installed before installing Inspektor Gadget"
  exit 1
fi

# Check if kubectl gadget already works
if [ "$(kubectl gadget version)" != "v0.2.0" ] ; then
  echo "INFO: Inspektor Gadget is already installed"
  exit 0
fi

# Check if krew is installed
if kubectl krew >/dev/null 2>&1; then
  echo "INFO: Installing Inspektor Gadget with Krew"
  kubectl krew install gadget
else
  if [[ ! -f inspektor-gadget-linux-amd64.tar.gz ]]; then
    echo "INFO: Downloading Inspektor Gadget"
    wget https://github.com/kinvolk/inspektor-gadget/releases/download/v0.2.0/inspektor-gadget-linux-amd64.tar.gz
  fi
  echo "INFO: Verifying the downloaded file"
  sha256sum -c <<EOF
b2d5e70a5caa4adfa3918e8a70702cd4a118d5ebafc091d5b4d7ec4ea0caf390  inspektor-gadget-linux-amd64.tar.gz
EOF
  if [[ $? -ne 0 ]]; then
    echo "ERROR: failed while verifying downloaded file"
    exit 2
  fi

  echo "INFO: Extracting kubectl-gadget from downloaded file"
  tar xf inspektor-gadget-linux-amd64.tar.gz kubectl-gadget

  KUBE_PATH=$(dirname $(which kubectl))
  if [[ -w ${KUBE_PATH} ]]; then
    echo "INFO: Copying kubectl-gadget to ${KUBE_PATH}"
    cp kubectl-gadget ${KUBE_PATH}
  else
    echo "INFO: Attempting to use sudo to copy kubectl-gadget to ${KUBE_PATH}"
    sudo cp kubectl-gadget ${KUBE_PATH}
  fi
fi

echo "INFO: Verifying that Inspektor Gadget got installed correctly"
kubectl gadget version
if [[ $? -ne 0 ]]; then
  echo "ERROR: failed while verifying that Inspektor Gadget is installed"
  exit 3
fi
