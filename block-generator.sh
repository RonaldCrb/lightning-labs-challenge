RPC_PASS='changeme'
RPC_USER='satoshi'
RPC_PORT='18444'
NETWORK='regtest'

echo "Generating a block every 10 seconds. Press [CTRL+C] to stop.."

BITCOIND_ADDRESS=$(kubectl exec pod/bitcoind-0 -- bitcoin-cli -$NETWORK -rpcpassword=$RPC_PASS -rpcuser=$RPC_USER -rpcport=18444 getnewaddress)

while :
do
  echo "Generate a new block `date '+%d/%m/%Y %H:%M:%S'`"
  kubectl exec pod/bitcoind-0 -- bitcoin-cli -$NETWORK -rpcpassword=$RPC_PASS -rpcuser=$RPC_USER -rpcport=18444 generatetoaddress 1 "$BITCOIND_ADDRESS"
  sleep 10
done