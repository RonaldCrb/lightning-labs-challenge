# Lightning Labs Code Challenge
Reference -> https://docs.google.com/document/d/1I83EFLwSFiSo_3WfLPbLMLjN363kw2cPKa23UTOyU6M/edit?pli=1#

This Repository contains all required pieces to setup the following:

1. bitcoind node
2. lnd-alice node
3. lnd-bob node

## Requirements
for running this stack you will need a fresh version of:

- docker
- minikube
- kubectl
- helm

## Steps
- if your minikube instance is not running, start it now `minikube start` 
- go to `/SECRETS/bitcoin.conf` and set the RPC password and user name of your choice
- go to `/SECRETS/lnd.conf` and match the bitcoind RPC username and Password the same as you used in the step above
- run `bootstrap.sh`
- run `setup.sh` to bootstrap the network. the end result of this script should be the payment confirmations sending some sats lnd-alice <-> lnd-bob 
- after youre done, just run `cleanup.sh`
- if youre really done, you can delete the nodes data with `docker exec minikube rm -rf /data/bitcoind /data/lnd-alice /data/lnd-bob`

## optional
you can use the `block-generator.sh` script in order to mine 1 block every 10 seconds. (dont forget to update RPC user and password at the top)

## In Progress
- gitops advanced challenge

## known problems
- by switching `securityContext.enabled` in the `lnd` chart, the `lndinit` process panics with a nil pointer deref

<img title="Memory Sege" alt="Alt text" src="./panic-nil-pointer.png">

## fixed problems
- The solution for this was to delete the secret template from the lnd chart and allow the lndinit process to control the secrets for wallet credentials; for this to work we also need to add the `create` verb to the `Role` template such that the lndinit process is authorized to create new secrets in k8s. 

~~depending on your minikube storage configuration, when running `cleanup.sh` and attempting `bootstrap.sh` again or when re-running `bootstrap.sh`, you will find this error... it can be fixed by deleting the lnd volumes inside the minikube host. (for me that means just running `docker exec minikube rm -rf /data/lnd-bob /data/lnd-alice` as soon as i get the crashloops on LND workloads); this effectively initializes the node with a new seed and wallet password. if you run `cleanup.sh` the secrets containing the seed and wallet password are going to be deleted, therefore if you want to be safe, make sure that you take note of those before performing any potentially destructive actions.~~

<img title="invalid passphrase" alt="invalid passphrase" src="./inv-passphrase.png">