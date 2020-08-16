#!/bin/bash

# conntrack is needed when running Minikube with the none driver
sudo apt-get install conntrack

# The docker service needs to be enabled
sudo systemctl enable docker.service

# And writing to regular files needs to be unrestricted
sudo sysctl fs.protected_regular=0
