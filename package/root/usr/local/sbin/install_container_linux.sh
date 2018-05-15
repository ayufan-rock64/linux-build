#!/bin/bash

echo "Container Linux installation script"
echo "This will install:"
echo " - Docker Community Edition"
echo " - Docker Compose"
echo " - Kubernetes: kubeadm, kubelet and kubectl"
echo ""

set -xeo pipefail

apt-get update -y
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

# TODO: workaround, add xenial for now
RELEASE=$(lsb_release -cs)
if [[ "$RELEASE" == "bionic" ]]; then
    RELEASE=xenial
fi

add-apt-repository \
   "deb https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") $RELEASE stable"

add-apt-repository \
   "deb http://apt.kubernetes.io/ kubernetes-$RELEASE main"

apt-get update -y
apt-get install -y docker-ce docker-compose kubelet kubeadm kubectl
