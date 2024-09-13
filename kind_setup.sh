#!/bin/sh

set -x


# Pre-requisites (see readme)
# 1. Install kind  - for mac "brew install kind"
# 2. Install kubectl - for mac "brew install kubectl"
# 3. Install istio - this was tested against istio 1.23 (https://github.com/istio/istio/releases/tag/1.23.1)


# Define some istio ports (k8 container port and K8 nodePort - note we expose the nodeports as hostports in Kind)
# This will allow you to access the ingress gateway via port 8080 (e.g. http://localhost:8080/productpage )

export ISTIO_HTTP_PORT=8080
export ISTIO_HTTP_NODE_PORT=31590
export ISTIO_HTTPS_PORT=8443
export ISTIO_HTTPS_NODE_PORT=31591
export ISTIO_STATUS_PORT=8221
export ISTIO_STATUS_NODE_PORT=31592

kind create cluster \
  --wait 120s \
  --config - <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: istio-quickstart
nodes:
  - role: control-plane
    kubeadmConfigPatches:
      - |
        kind: InitConfiguration
        nodeRegistration:
          kubeletExtraArgs:
            node-labels: "ingress-ready=true"
    extraPortMappings:
    - containerPort: $ISTIO_HTTP_NODE_PORT  # Istio HTTP
      hostPort: $ISTIO_HTTP_PORT
      protocol: TCP
    - containerPort: $ISTIO_HTTPS_NODE_PORT # Istio HTTPS/TLS
      hostPort: $ISTIO_HTTPS_PORT
      protocol: TCP
    - containerPort: $ISTIO_STATUS_NODE_PORT # Istio status port
      hostPort: $ISTIO_STATUS_PORT
      protocol: TCP      
  
EOF

# This assumes you have Istio installed
echo "Installing Istio"

rm -rf istio-profile.yaml

envsubst < istio-profile-template.yaml > istio-profile.yaml 

istioctl install -f istio-profile.yaml -y


echo "Setting up default namespace for Istio"
kubectl label namespace default istio-injection=enabled

# echo "Installing CRD's"
kubectl get crd gateways.gateway.networking.k8s.io &> /dev/null || \
  { kubectl kustomize "github.com/kubernetes-sigs/gateway-api/config/crd?ref=v1.1.0" | kubectl apply -f -; }


echo "Installing demo app" 
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.23/samples/bookinfo/platform/kube/bookinfo.yaml

echo "Install the gateway"

kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.23/samples/bookinfo/networking/bookinfo-gateway.yaml

echo "Demo installed
