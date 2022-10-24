# Lightning Labs Code Challenge
Reference -> https://docs.google.com/document/d/1I83EFLwSFiSo_3WfLPbLMLjN363kw2cPKa23UTOyU6M/edit?pli=1#

## Base Challenge

This Repository contains all required pieces to setup the following:

1. bitcoind node
2. lnd-alice node
3. lnd-bob node

### Requirements
for running this stack you will need a fresh version of:

- docker
- minikube
- kubectl
- helm

### Steps
- if your minikube instance is not running, start it now `minikube start` 
- go to `/SECRETS/bitcoin.conf` and set the RPC password and user name of your choice
- go to `/SECRETS/lnd.conf` and match the bitcoind RPC username and Password the same as you used in the step above
- run `bootstrap.sh`
- after youre done, just run `cleanup.sh`


### In Progress
- fixing lndinit config such that it stores the TLS certificate and macaroons to k8s secrets.
- creating the program that performs the following actions:
  - generate alice new on-chain address
  - mine few blocks using alice address to receive mining rewards
  - use mining rewards to open channels to bob
  - make some payments thru said channels to bob and back to alice
- gitops advanced challenge

### known problems
- depending on your minikube storage configuration, when running `cleanup.sh` and attempting `bootstrap.sh` again or when re-running `bootstrap.sh`, you will find this error... it can be fixed by deleting the lnd volumes inside the minikube host. (for me that means just running `docker exec minikube rm -rf /data/lnd-bob /data/lnd-alice` as soon as i get the crashloops on LND workloads); this effectively initializes the node with a new seed and wallet password. if you run `cleanup.sh` the secrets containing the seed and wallet password are going to be deleted, therefore if you want to be safe, make sure that you take note of those before performing any potentially destructive actions.

<img title="invalid passphrase" alt="invalid passphrase" src="./inv-passphrase.png">


- by switching `securityContext.enabled` in the `lnd` chart, the `lndinit` process panics with a nil pointer deref

<img title="Memory Sege" alt="Alt text" src="./panic-nil-pointer.png">

## Advanced Challenge 3 -> GitOps
For this challenge ive selected ArgoCD

### requirements
- argocd (the CLI tool from -> https://argo-cd.readthedocs.io/en/stable/cli_installation)
- github personal access token (the classic one, not the new scoped ones)

### steps
1. if your minikube instance is not runnig, start it now `minikube start`
2. fill your github credentials in the `go-gitops.sh` file OR use the env vars $GITHUB_USER and $GITHUB_PAT in your environment
3. run `bootstrap-gitops.sh` to deploy argocd pods to minikube
4. wait until all pods are ready and run `connect-gitops.sh` on a secondary terminal
5. run `go-gitops.sh` on your primary terminal

### how it works

- place your `ApplicationSet` manifests at `GITOPS/sets` this will inform argocd of the existence of apps and where to find its config values
- place an umbrella helm chart with any amount of children charts as per your requirement
- override the values in the umbrella chart as per your requirement

the ApplicationSet manifest allows us to have multiple environments of the same umbrella chart. 