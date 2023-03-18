Instructions for manually setting up a node on Gitshock Cartenz Chain using geth and teku.

### Prerequisites

[Install golang](https://go.dev/doc/install) for your system.

Then:
```
sudo apt install -y git default-jre make gcc
```

### Manual Setup


Generate jwt
openssl rand -hex 32 | tr -d "\n" > "/tmp/jwtsecret"


## Execution Layer
Download and build software from source:

git clone https://github.com/ethereum/go-ethereum.git
cd go-ethereum
make geth


Ubuntu OS Via PPAs: 

sudo add-apt-repository -y ppa:ethereum/ethereum

Then, to install the stable version of go-ethereum:
sudo apt-get update
sudo apt-get install ethereum


Initialise:
geth init --datadir "datadir-geth" ~/testnet-all/genesis.json

Run:
geth \
     --networkid {networkID} \
     --syncmode=full \
     --port 30303 \
     --http \
     --datadir "datadir-geth" \
     --authrpc.jwtsecret=/tmp/jwtsecret \
     --bootnodes {bootnodes}
     
     
## Consensus Layer
Open a new terminal session.

Download and build software:

git clone https://github.com/ConsenSys/teku.git
cd teku
./gradlew installDist

Run:

teku \
    --network ~/testnet-all/config.yaml \
    --initial-state ~/testnet-all/genesis.ssz \
    --data-path "datadir-teku" \
    --ee-endpoint http://localhost:8551 \
    --ee-jwt-secret-file "/tmp/jwtsecret" \
    --log-destination console \
    --p2p-discovery-bootnodes {bootnodes}