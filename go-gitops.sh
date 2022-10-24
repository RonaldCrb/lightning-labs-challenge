#!/bin/bash
GITHUB_USER='your Github'
GITHUB_PAT='Your github Personal Access Token'
NAMESPACE=argocd
ARGO_PASS=$(kubectl -n $NAMESPACE get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo)

argocd login localhost:9090 \
  --insecure \
  --username admin \
  --password $ARGO_PASS  

# Repo/App
argocd repo add https://github.com/RonaldCrb/lightning-labs-challenge --username $GITHUB_USER --password $GITHUB_PAT
argocd app create main --repo https://github.com/RonaldCrb/lightning-labs-challenge.git --path GITOPS/sets --dest-server https://kubernetes.default.svc
