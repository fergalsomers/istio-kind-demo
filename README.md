
# Simple Kind demo that installs Istio

This is a demo repository that uses Kind to install istio into a demo cluster and installs the demo application. 
- It sets up istio so that your local port 80 is mapped to the istioingress-gateway port so that you can view the demo application from your laptop's browser. 


# Pre-requisites

You must have the following software installed:

- Install kind  - for mac "brew install kind"
- Install kubectl - for mac "brew install kubectl"
- Download Install istio - this was tested against istio 1.23 (https://github.com/istio/istio/releases/tag/1.23.1) - require istioctl tool is on your $PATH
- Install gettext - for mac "brew install gettext" (installs the envsubst cli tool)

# To run

```
$ ./kind_setup.sh 
```

# To test

Point your browser at [localhost:8080/productpage](http://localhost:8080/productpage) or use the curl command below:

```
curl http://localhost:8080/productpage
```

