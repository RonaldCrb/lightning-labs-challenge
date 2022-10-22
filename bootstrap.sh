#!/bin/sh
NAMESPACE=base-challenge
BITCOIND_CHART="CHARTS/bitcoind"
BITCOIND_RELEASE="bitcoind"
LND_CHART="CHARTS/lnd"
LND_ALICE_RELEASE="lnd-alice"
LND_BOB_RELEASE="lnd-bob"
CYAN='\033[0;36m'
NC='\033[0m' # No Color

printf "${CYAN}⎈ Creating namespace base-challenge ⎈${NC}\n"
kubectl create namespace base-challenge

printf "${CYAN}⎈ Applying secrets ⎈${NC}\n"
kubectl create secret generic bitcoind-conf --from-file=bitcoin.conf=./SECRETS/bitcoin.conf --namespace base-challenge
kubectl create secret generic lnd-conf --from-file=lnd.conf=./SECRETS/lnd.conf --namespace base-challenge

printf "${CYAN}⎈ Installing bitcoind ⎈${NC}\n"
helm upgrade --install $BITCOIND_RELEASE -f VALUES/values-bitcoind.yaml --namespace $NAMESPACE $BITCOIND_CHART
printf "${CYAN}⎈ Installing lnd-alice ⎈${NC}\n"
helm upgrade --install $LND_ALICE_RELEASE -f VALUES/values-alice.yaml --namespace $NAMESPACE $LND_CHART
printf "${CYAN}⎈ Installing lnd-bob ⎈${NC}\n"
helm upgrade --install $LND_BOB_RELEASE -f VALUES/values-bob.yaml --namespace $NAMESPACE $LND_CHART