#!/bin/bash

# Check that kubectl is installed
if ! kubectl version --client=true >/dev/null 2>&1; then
  echo "ERROR: Can't execute kubectl."
  echo "Make sure kubectl is installed before installing kubectl-trace"
  exit 1
fi

# Check if kubectl trace already works
if kubectl trace version >/dev/null 2>&1; then
  echo "INFO: kubectl-trace is already installed"
  exit 0
fi

# Check if krew is installed
if kubectl krew >/dev/null 2>&1; then
  echo "INFO: Installing kubectl-trace with Krew"
  kubectl krew install trace
else
  if [[ ! -f kubectl-trace_0.1.0-rc.1_linux_amd64.tar.gz ]]; then
    echo "INFO: Downloading kubectl-trace"
    wget https://github.com/iovisor/kubectl-trace/releases/download/v0.1.0-rc.1/kubectl-trace_0.1.0-rc.1_linux_amd64.tar.gz
  fi
  echo "INFO: Verifying the downloaded file"
  sha256sum -c <<EOF
cd151705bb5e8964aef5f4f8a6443dcdaef5ea66f5960371404e18b47edd485f  kubectl-trace_0.1.0-rc.1_linux_amd64.tar.gz
EOF
  if [[ $? -ne 0 ]]; then
    echo "ERROR: failed while verifying downloaded file"
    exit 2
  fi

  echo "INFO: Extracting kubectl-trace from downloaded file"
  tar xf kubectl-trace_0.1.0-rc.1_linux_amd64.tar.gz kubectl-trace

  KUBE_PATH=$(dirname $(which kubectl))
  if [[ -w ${KUBE_PATH} ]]; then
    echo "INFO: Copying kubectl-trace to ${KUBE_PATH}"
    cp kubectl-trace ${KUBE_PATH}
  else
    echo "INFO: Attempting to use sudo to copy kubectl-trace to ${KUBE_PATH}"
    sudo cp kubectl-trace ${KUBE_PATH}
  fi
fi

echo "INFO: Verifying that kubectl-trace got installed correctly"
kubectl trace version
if [[ $? -ne 0 ]]; then
  echo "ERROR: failed while verifying that kubectl-trace is installed"
  exit 3
fi
