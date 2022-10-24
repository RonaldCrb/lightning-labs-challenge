RPC_PASS='changeme'
RPC_USER='satoshi'
RPC_PORT='18444'
NETWORK='regtest'

echo '=> creating bitcoind wallet'
kubectl exec pod/bitcoind-0 -- bitcoin-cli -$NETWORK -rpcpassword=$RPC_PASS -rpcuser=$RPC_USER -rpcport=18444 createwallet 'satoshi'

echo '=> Getting new address from lnd-alice'
ALICE_ADDRESS=$(kubectl exec pod/lnd-alice-0 -- lncli --network=$NETWORK newaddress p2wkh | jq -r '.address')

echo "=> mining the first 20 blocks to alice address -> $ALICE_ADDRESS"
kubectl exec pod/bitcoind-0 -- bitcoin-cli -$NETWORK -rpcpassword=$RPC_PASS -rpcuser=$RPC_USER -rpcport=18444 generatetoaddress 20 "$ALICE_ADDRESS"

echo '=> getting new bitcoind address'
BITCOIND_ADDRESS=$(kubectl exec pod/bitcoind-0 -- bitcoin-cli -$NETWORK -rpcpassword=$RPC_PASS -rpcuser=$RPC_USER -rpcport=18444 getnewaddress)

echo "=> mining the first 101 blocks to bitcoind address -> $BITCOIND_ADDRESS"
kubectl exec pod/bitcoind-0 -- bitcoin-cli -$NETWORK -rpcpassword=$RPC_PASS -rpcuser=$RPC_USER -rpcport=18444 generatetoaddress 101 "$BITCOIND_ADDRESS"

echo "=> checking alice wallet balance"
kubectl exec pod/lnd-alice-0 -- lncli --network=$NETWORK walletbalance

echo "=> getting lnd-bob public key"
BOB_PUBLIC_KEY=$(kubectl exec pod/lnd-bob-0 -- lncli --network=regtest getinfo | jq -r '.identity_pubkey')

echo "=> awaiting for nodes to be ready..."
ALICE_STATUS=$(kubectl exec pod/lnd-alice-0 -- lncli state | jq -r '.state')
BOB_STATUS=$(kubectl exec pod/lnd-bob-0 -- lncli state | jq -r '.state')

while [[ "$ALICE_STATUS" != "SERVER_ACTIVE" && "$BOB_STATUS" != "SERVER_ACTIVE" ]]; do
  echo "lnd-alice status => $ALICE_STATUS"
  echo "lnd-bob status => $BOB_STATUS"
  sleep 5
  ALICE_STATUS=$(kubectl exec pod/lnd-alice-0 -- lncli state | jq -r '.state')
  BOB_STATUS=$(kubectl exec pod/lnd-bob-0 -- lncli state | jq -r '.state')
done

sleep 5

echo "=> Connecting to lnd-bob from lnd-alice"
kubectl exec pod/lnd-alice-0 -- lncli --network=$NETWORK connect $BOB_PUBLIC_KEY@lnd-bob.base-challenge.svc.cluster.local

echo "=> opening channel lnd-alice -> lnd-bob"
kubectl exec pod/lnd-alice-0 -- lncli --network=$NETWORK openchannel --node_key="$BOB_PUBLIC_KEY" --local_amt=10000000 --sat_per_vbyte 1

echo "=> listing pending channels from lnd-bob"
kubectl exec pod/lnd-bob-0 -- lncli --network=$NETWORK pendingchannels

echo "=> mining 6 blocks to bitcoind address -> $BITCOIND_ADDRESS"
kubectl exec pod/bitcoind-0 -- bitcoin-cli -$NETWORK -rpcpassword=$RPC_PASS -rpcuser=$RPC_USER -rpcport=18444 generatetoaddress 6 "$BITCOIND_ADDRESS"

echo "=> listing pending channels from lnd-bob"
kubectl exec pod/lnd-bob-0 -- lncli --network=$NETWORK pendingchannels

echo "=> requesting invoice from bob"
BOB_INVOICE=$(kubectl exec pod/lnd-bob-0 -- lncli --network=regtest addinvoice | jq -r '.payment_request')

echo "=> sending some sats from alice to bob"
kubectl exec pod/lnd-alice-0 -- lncli --network=regtest sendpayment --pay_req=$BOB_INVOICE --amt=5000000 --force

echo "=> requesting invoice from alice"
ALICE_INVOICE=$(kubectl exec pod/lnd-alice-0 -- lncli --network=regtest addinvoice | jq -r '.payment_request')

echo "=> sending some sats from alice to bob"
kubectl exec pod/lnd-bob-0 -- lncli --network=regtest sendpayment --pay_req=$ALICE_INVOICE --amt=100000 --force