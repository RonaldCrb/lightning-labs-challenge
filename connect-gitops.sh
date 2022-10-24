NAMESPACE=argocd

kubectl -n $NAMESPACE port-forward svc/argocd-server 9090:80