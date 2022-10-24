#!/bin/bash
NAMESPACE=argocd

kubectl create namespace $NAMESPACE
kubectl apply -n $NAMESPACE -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
