NodesCount=2
LogLevel=info
######## Checker Functions
function Log() {
	echo
	echo "--> $@"
}
function CheckGeth()
{
	Log "Checking Geth $1"
	test -z $my_ip && my_ip=`curl ifconfig.me 2>/dev/null` && Log "my_ip=$my_ip"
	geth attach --exec "admin.nodeInfo.enode" data/execution/$1/geth.ipc | sed s/^\"// | sed s/\"$//
	echo Peers: `geth attach --exec "admin.peers" data/execution/$1/geth.ipc | grep "remoteAddress" | grep -e $my_ip -e "127.0.0.1"`
	echo Block Number: `geth attach --exec "eth.blockNumber" data/execution/$1/geth.ipc`
}
function CheckBeacon()
{
	Log "Checking Beacon $1"
	echo My ID: `curl http://localhost:$((9596 + $1))/eth/v1/node/identity 2>/dev/null | jq -r ".data.peer_id"`
	echo My enr: `curl http://localhost:$((9596 + $1))/eth/v1/node/identity 2>/dev/null | jq -r ".data.enr"`
	echo Peer Count: `curl http://localhost:$((9596 + $1))/eth/v1/node/peers 2>/dev/null | jq -r ".meta.count"`
	curl http://localhost:$((9596 + $1))/eth/v1/node/syncing 2>/dev/null | jq
}
function CheckBeacon_Prysm()
{
	Log "Checking Beacon $1"
	curl localhost:$((8000 + $1))/p2p
	curl http://localhost:$((8000 + $1))/healthz
	curl http://localhost:$((3500 + $1))/eth/v1/node/syncing 2>/dev/null | jq
}
function CheckAll()
{
	for i in $(seq 0 $(($NodesCount-1))); do
		CheckGeth $i
	done
	for i in $(seq 0 $(($NodesCount-1))); do
		CheckBeacon $i
	done
}
########

function KillAll() {
	Log "Kill All Apps"
	killall geth beacon-chain validator
	pkill -f ./prysm.*
	pkill -f lodestar.js
	docker compose -f /home/adigium/eth-pos-devnet/docker-run.yml down || echo Looks like docker is not running.
}
function PrepareEnvironment() {
	Log "Cleaning Environment"
	KillAll
	
	git clean -fxd
	rm execution/bootnodes.txt consensus/bootnodes.txt

	test -d logs || mkdir logs
	test -d data || mkdir data
	test -d data/wallet_dir || mkdir data/wallet_dir
	if [[ -d ../validator_keys8 ]]; then
		rm consensus/validator_keys/*
		cp -R ../validator_keys8/* consensus/validator_keys
	fi

	my_ip=`curl ifconfig.me 2>/dev/null` && Log "my_ip=$my_ip"
}
function AdjustTimestamps {
	timestamp=`date +%s`	
	timestampHex=`printf '%x' $timestamp`
	Log "timestamp=$timestamp"
	Log "timestampHex=$timestampHex"

	sed -i s/\"timestamp\":.*/\"timestamp\":\"0x$timestampHex\",/g execution/genesis.json
	sed -i s/MIN_GENESIS_TIME:.*/"MIN_GENESIS_TIME: $timestamp"/g consensus/config.yaml
}
function InitGeth()
{
	Log "Initializing geth $1"
	geth init \
	  --datadir "./data/execution/$1" \
	  ./execution/genesis.json
}
function ImportGethAccount()
{
	Log Importing Account [Your Address]
	echo "[Your Password]" > data/execution/geth_password.txt
	echo "[You PrivateKey]" > data/execution/account_geth_privateKey
	geth --datadir=data/execution/0 account import --password data/execution/geth_password.txt data/execution/account_geth_privateKey
}
function RunGeth()
{
	Log "Running geth $1 on port $((8551 + $1))"
	local bootnodes=$(cat execution/bootnodes.txt 2>/dev/null | tr '\n' ',' | sed s/,$//g)
	echo "Geth Bootnodes = $bootnodes"
	nohup geth \
		--http \
		--http.port $((8545 + $1)) \
		--http.api=eth,net,web3,personal,miner \
		--http.addr=0.0.0.0 \
		--http.vhosts=* \
		--http.corsdomain=* \
	  --networkid 1881 \
	  --datadir "./data/execution/$1" \
	  --authrpc.port $((8551 + $1)) \
	  --port $((30303 + $1)) \
	  --syncmode full \
	  --bootnodes=$bootnodes \
	  > ./logs/geth_$1.log &
	sleep 1 # Set to 5 seconds to allow the geth to bind to the external IP before reading enode
	#local variablename="bootnode_geth_$1"
	#export $variablename=`geth attach --exec "admin.nodeInfo.enode" data/execution/$1/geth.ipc | sed s/^\"// | sed s/\"$//`
	#Log "$variablename = ${!variablename}"
	#echo ${!variablename} >> execution/bootnodes.txt
	local my_enode=$(geth attach --exec "admin.nodeInfo.enode" data/execution/$1/geth.ipc | sed s/^\"// | sed s/\"$// | sed s/'127.0.0.1'/$my_ip/)
	echo $my_enode >> execution/bootnodes.txt
}
function StoreGethHash() {
	genesis_hash=`geth attach --exec "eth.getBlockByNumber(0).hash" data/execution/1/geth.ipc | sed s/^\"// | sed s/\"$//`

	echo $genesis_hash > execution/genesis_hash.txt
	echo $genesis_hash > consensus/deposit_contract_block.txt
	sed -i s/TERMINAL_BLOCK_HASH:.*/"TERMINAL_BLOCK_HASH: $genesis_hash"/g consensus/config.yaml
	cat consensus/config.yaml|grep TERMINAL_BLOCK_HASH
	Log "genesis_hash = $genesis_hash"
}
function GenerateGenesisSSZ()
{
	Log "Generating Beaconchain Genesis"
	eth2-testnet-genesis merge \
	  --config "./consensus/config.yaml" \
	  --eth1-config "./execution/genesis.json" \
	  --mnemonics "./consensus/mnemonic.yaml" \
	  --state-output "./consensus/genesis.ssz" \
	  --tranches-dir "./consensus/tranches"
}
function RunBeacon() {
	Log "Running Beacon $1"
	local bootnodes=`cat consensus/bootnodes.txt 2>/dev/null | grep . | tr '\n' ',' | sed s/,$//g`
	echo "Beacon Bootnodes = $bootnodes"
	
	nohup lodestar beacon \
	  --suggestedFeeRecipient "0x491B71563896B31e8451C8aD3546cEdEfb125563" \
	  --execution.urls "http://127.0.0.1:$((8551 + $1))" \
	  --jwt-secret "./data/execution/$1/geth/jwtsecret" \
	  --dataDir "./data/consensus/$1" \
	  --paramsFile "./consensus/config.yaml" \
	  --genesisStateFile "./consensus/genesis.ssz" \
	  --enr.ip $my_ip \
	  --rest.port $((9596 + $1)) \
	  --port $((9000 + $1)) \
	  --network.connectToDiscv5Bootnodes true \
	  --logLevel $LogLevel \
	  --bootnodes=$bootnodes \
	  > ./logs/beacon_$1.log &

	  #--eth1=true \
	  #--eth1.providerUrls=http://localhost:$((8545 + $1)) \
	  #--execution.urls=http://localhost:$((8545 + $1)) \
	  #--subscribeAllSubnets=true \
	  
	echo Waiting for Beacon enr ...
	local my_enr=''
	while [[ -z $my_enr ]]
	do
		sleep 1
		my_enr=`curl http://localhost:$((9596 + $1))/eth/v1/node/identity 2>/dev/null | jq -r ".data.enr"`
	done
	echo "My Enr = $my_enr"
	echo $my_enr >> consensus/bootnodes.txt
}

function RunBeacon_Prysm() {
	Log "Running Beacon $1"
	local bootnodes=`cat consensus/bootnodes.txt 2>/dev/null | grep . | tr '\n' ',' | sed s/,$//g`
	echo "Beacon Bootnodes = $bootnodes"
	
	nohup beacon-chain \
	  --min-sync-peers=$i \
	  --suggested-fee-recipient "0x491B71563896B31e8451C8aD3546cEdEfb125563" \
	  --execution-endpoint=http://localhost:$((8551 + $1)) \
	  --jwt-secret "./data/execution/$1/geth/jwtsecret" \
	  --datadir "./data/consensus/$1" \
	  --chain-config-file=consensus/config.yaml \
	  --config-file=consensus/config.yaml \
	  --genesis-state "./consensus/genesis.ssz" \
	  --contract-deployment-block=0 \
	  --verbosity $LogLevel \
	  --bootstrap-node=$bootnodes \
	  --rpc-host=0.0.0.0 \
	  --grpc-gateway-host=0.0.0.0 \
	  --monitoring-host=0.0.0.0 \
	  --p2p-host-ip=$my_ip \
	  --accept-terms-of-use \
	  --chain-id=32382 \
	  --rpc-port=$((4010 + $1)) \
	  --p2p-tcp-port=$((13000 + $1)) \
	  --p2p-udp-port=$((12000 + $1)) \
	  --grpc-gateway-port=$((3500 + $1)) \
	  --monitoring-port=$((8000 + $1)) \
	  > ./logs/beacon_$1.log &

	echo Waiting for Beacon enr ...
	local my_enr=''
	while [[ -z $my_enr ]]
	do
		sleep 1
		my_enr=$(curl localhost:8000/p2p 2>/dev/null | grep ^self= | sed s/self=//g | sed s/,\\/ip4.*//g)
	done
	echo "My Enr = $my_enr"
	echo $my_enr >> consensus/bootnodes.txt
}

function RunBeacon_Lighthouse() {
	Log "Running Beacon $1"
	local bootnodes=`cat consensus/bootnodes.txt 2>/dev/null | grep . | tr '\n' ',' | sed s/,$//g`
	echo "Beacon Bootnodes = $bootnodes"
	
	nohup lighthouse beacon \
		--eth1 \
		--http \
		--reset-payload-statuses \
		--staking \
		--subscribe-all-subnets \
		--validator-monitor-auto \
		--enable-private-discovery \
		--boot-nodes=$bootnodes \
		--datadir "./data/consensus/$1" \
		--debug-level $LogLevel \
		--eth1-endpoints "http://127.0.0.1:$((8545 + $1))" \
		--execution-endpoint "http://127.0.0.1:$((8551 + $1))" \
		--execution-jwt "./data/execution/$1/geth/jwtsecret" \
		--graffiti "John.Risk" \
		--http-allow-origin * \
		--http-port $((5052 + $1)) \
		--port $((9000 + $1)) \
		--suggested-fee-recipient "0x491B71563896B31e8451C8aD3546cEdEfb125563" \
		--target-peers $1 \
		--testnet-dir consensus \


	  --paramsFile "./consensus/config.yaml" \
	  --genesisStateFile "./consensus/genesis.ssz" \
	  > ./logs/beacon_$1.log &

	echo Waiting for Beacon enr ...
	local my_enr=''
	while [[ -z $my_enr ]]
	do
		sleep 1
		my_enr=`curl http://localhost:$((9596 + $1))/eth/v1/node/identity 2>/dev/null | jq -r ".data.enr"`
	done
	echo "My Enr = $my_enr"
	echo $my_enr >> consensus/bootnodes.txt
}

function RunValidator()
{
	Log "Running Validators $1"
	cp -R consensus/validator_keys consensus/validator_keys_$1
	nohup lodestar validator \
	  --dataDir "./data/consensus/$1" \
	  --beaconNodes "http://127.0.0.1:$((9596 + $1))" \
	  --suggestedFeeRecipient "0x491B71563896B31e8451C8aD3546cEdEfb125563" \
	  --graffiti "JOY MERGEDNET YOLO LODESTAR" \
	  --paramsFile "./consensus/config.yaml" \
	  --importKeystores "./consensus/validator_keys_$1" \
	  --importKeystoresPassword "./consensus/validator_keys_$1/password.txt" \
	  --logLevel $LogLevel \
	  > ./logs/validator_$1.log &
}
function RunValidator_Prysm()
{
	Log "Running Validators $1"
	cp -R consensus/validator_keys consensus/validator_keys_$1
	CreateWallet_Prysm $1
	nohup validator \
	  --datadir "./data/consensus/$1" \
	  --beacon-rpc-provider=localhost:$((4010 + $1)) \
	  --beacon-rpc-gateway-provider=localhost:$((3500 + $1)) \
	  --accept-terms-of-use \
  	  --graffiti "YOLO MERGEDNET GETH PRYSMSTAR" \
	  --suggested-fee-recipient "0xCaA29806044A08E533963b2e573C1230A2cd9a2d" \
	  --chain-config-file "./consensus/config.yaml" \
	  --wallet-dir=data/wallet_dir/$1 \
	  --wallet-password-file=consensus/validator_keys_$1/password.txt \
	  --verbosity $LogLevel \
	  > ./logs/validator_$1.log &
}
function CreateWallet_Prysm() {
	# Import Wallet and Accounts
	mkdir data/wallet_dir/$1
	#cp /root/prysm/validator .

	clients/validator \
		accounts \
		import \
		--accept-terms-of-use \
		--keys-dir=consensus/validator_keys_$1/ \
		--wallet-dir=data/wallet_dir/$1 \
		--wallet-password-file=consensus/validator_keys_$1/password.txt \
		--account-password-file=consensus/validator_keys_$1/password.txt
}
function RunStaker {
	local folder=/root/validator_keys8_other
	echo {\"keys\":$(cat `ls -rt $folder/deposit_data* | tail -n 1`), \"address\":\"0xF359C69a1738F74C044b4d3c2dEd36c576A34d9f\", \"privateKey\": \"0x28fb2da825b6ad656a8301783032ef05052a2899a81371c46ae98965a6ecbbaf\"} > $folder/payload.txt
	
	curl -X POST -H "Content-Type: application/json" -d @$folder/payload.txt http://localhost:8005/api/account/stake

	nohup lodestar validator \
	  --dataDir "./data/consensus/1" \
	  --beaconNodes "http://127.0.0.1:9597" \
	  --suggestedFeeRecipient "0xF359C69a1738F74C044b4d3c2dEd36c576A34d9f" \
	  --graffiti "CARTENZ YOLO MERGEDNET STAR" \
	  --paramsFile "./consensus/config.yaml" \
	  --importKeystores "$folder" \
	  --importKeystoresPassword "$folder/password.txt" \
	  --logLevel $LogLevel \
	  > ./logs/validator_1.log &
}
#git clone https://github.com/q9f/mergednet.git
#cd mergednet

PrepareEnvironment
set -e
AdjustTimestamps

for i in $(seq 0 $(($NodesCount-1))); do
	InitGeth $i
	if [[ $i == 0 ]]; then
		ImportGethAccount
	fi
	RunGeth $i
done

StoreGethHash
GenerateGenesisSSZ

for i in $(seq 0 $(($NodesCount-1))); do
	RunBeacon $i
done

sleep 5

for i in $(seq 0 $(($NodesCount-1))); do
	RunValidator $i
done
#RunValidator 0

#RunStaker

CheckAll

echo "
clear && tail -f logs/geth_0.log -n1000
clear && tail -f logs/geth_1.log -n1000
clear && tail -f logs/beacon_0.log -n1000
clear && tail -f logs/beacon_1.log -n1000
clear && tail -f logs/validator_0.log -n1000
clear && tail -f logs/validator_1.log -n1000

curl http://localhost:9596/eth/v1/node/identity | jq
curl http://localhost:9596/eth/v1/node/peers | jq
curl http://localhost:9596/eth/v1/node/syncing | jq
"
