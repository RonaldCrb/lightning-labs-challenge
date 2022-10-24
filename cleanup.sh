#!/bin/sh
NAMESPACE=base-challenge
BITCOIND_RELEASE="bitcoind"
LND_ALICE_RELEASE="lnd-alice"
LND_BOB_RELEASE="lnd-bob"
CYAN='\033[0;36m'
NC='\033[0m' # No Color

printf "${CYAN}⎈ Uninstalling ${BITCOIND_RELEASE} chart ⎈${NC}\n"
helm delete $BITCOIND_RELEASE --namespace $NAMESPACE 
printf "${CYAN}⎈ Uninstalling ${LND_ALICE_RELEASE} chart ⎈${NC}\n"
helm delete $LND_ALICE_RELEASE --namespace $NAMESPACE 
printf "${CYAN}⎈ Uninstalling ${LND_BOB_RELEASE} chart ⎈${NC}\n"
helm delete $LND_BOB_RELEASE --namespace $NAMESPACE 
