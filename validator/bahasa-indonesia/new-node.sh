NodesCount=2
LOgLevel=info
###################### Checker Functions ######################
function Log() {
	echo
	echo "--> $1"
}
function CheckBeacon()
{
	Log "Checking Beacon $1"
	echo My ID: `curl http://localhost:$((9596 + $1))/eth/v1/node/identity 2>/dev/null | jq -r ".data.peer_id"`
	echo My enr: `curl http://localhost:$((9596 + $1))/eth/v1/node/identity 2>/dev/null | jq -r ".data.enr"`
	echo Peer Count: `curl http://localhost:$((9596 + $1))/eth/v1/node/peers 2>/dev/null | jq -r ".meta.count"`
	curl http://localhost:$((9596 + $1))/eth/v1/node/syncing 2>/dev/null | jq
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

###################### Setup Environments ######################
function KillAll() {
	Log "Kill All Apps"
	killall geth beacon-chain validator
	pkill -f lodestar.js
	docker compose -f /home/avenbreaks/kzg-ceremony/docker-run.yml down || echo Looks like docker is not running.
}
function PrepareEnvironment() {
	Log "Cleaning Environment"
	KillAll

	test -d logs || mkdir logs
	cp -R consensus/validator_keys consensus/validator_keys_1

	my_ip=`curl ifconfig.me 2>/dev/null` && Log "my_ip=$my_ip"
    echo "my_ip=$my_ip"
}
function InitGeth()
{
	Log "Initializing geth $1"
	geth init \
	  --datadir "./data/execution/$1" \
	  ./execution/genesis.json
}
function RunGeth()
{
	Log "Running geth $1 on port $((8551 + $1))"
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
		--bootnodes="enode://753cf9d1c9f8e1ccd7338ccc5d9e65b7cef9a345f8044d841a247da4c30155ba206091e322a4b82c366defd97a91b4f09d99113d6edf5a6309f96181cf2046fc@145.145.176.5:30303" \
		> ./logs/geth_$1.log &
	sleep 5
}
function RunBeacon() {
	Log "Running Beacon $1"	
	nohup lodestar beacon \
	  --suggestedFeeRecipient "0xCaA29806044A08E533963b2e573C1230A2cd9a2d" \
	  --execution.urls "http://127.0.0.1:$((8551 + $1))" \
	  --jwt-secret "./data/execution/$1/geth/jwtsecret" \
	  --dataDir "./data/consensus/$1" \
	  --paramsFile "./consensus/config.yaml" \
	  --genesisStateFile "./consensus/genesis.ssz" \
	  --enr.ip 127.0.0.1 \
	  --rest.port $((9596 + $1)) \
	  --port $((9000 + $1)) \
	  --network.connectToDiscv5Bootnodes true \
	  --logLevel $LogLevel \
	  --bootnodes="enr:-Ly4QDqCYmcgmImaBV3ZurDYJy0gJci4--UFeAn1hKUQy-ooSjI9DSCqlHK84FuPnX26Kvc0lm0En1E5Bb0yuXQFPP4Ch2F0dG5ldHOIAAAAAAAAAACEZXRoMpDymemfQAAAOP__________gmlkgnY0gmlwhJGRsAeJc2VjcDI1NmsxoQNg6ILeJoUPQwZ1-NJzxBrFRasxYMjTkA2xBkF9eRTUiYhzeW5jbmV0cwCDdGNwgiMog3VkcIIjKA" \
	  > ./logs/beacon_$1.log &

	sleep 1
	echo Waiting for Beacon enr ...
	local my_enr=`curl http://localhost:$((9596 + $1))/eth/v1/node/identity 2>/dev/null | jq -r ".data.enr"`
	while [[ -z $my_enr ]]
	do
		sleep 1
		local my_enr=`curl http://localhost:$((9596 + $1))/eth/v1/node/identity 2>/dev/null | jq -r ".data.enr"`
	done
	echo "My Enr = $my_enr"
	echo $my_enr >> consensus/bootnodes.txt
}
function CheckBeacon()
{
	Log "Checking Beacon $1"
	echo My ID: `curl http://localhost:$((9596 + $1))/eth/v1/node/identity 2>/dev/null | jq -r ".data.peer_id"`
	echo My enr: `curl http://localhost:$((9596 + $1))/eth/v1/node/identity 2>/dev/null | jq -r ".data.enr"`
	echo Peer Count: `curl http://localhost:$((9596 + $1))/eth/v1/node/peers 2>/dev/null | jq -r ".meta.count"`
	curl http://localhost:$((9596 + $1))/eth/v1/node/syncing 2>/dev/null | jq
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
function RunValidator()
{
	Log "Running Validators $1"
	cp -R consensus/validator_keys consensus/validator_keys_$1
	nohup lodestar validator \
	  --dataDir "./data/consensus/$1" \
	  --beaconNodes "http://127.0.0.1:$((9596 + $1))" \
	  --suggestedFeeRecipient "0xCaA29806044A08E533963b2e573C1230A2cd9a2d" \
	  --graffiti "Comdex Validators" \
	  --paramsFile "./consensus/config.yaml" \
	  --importKeystores "./consensus/validator_keys_$1" \
	  --importKeystoresPassword "./consensus/validator_keys_$1/password.txt" \
	  --logLevel $LogLevel \
	  > ./logs/validator_$1.log &
}

PrepareEnvironment

for i in $(seq 0 $(($NodesCount-1))); do
	InitGeth $i
	RunGeth $i
done

for i in $(seq 0 $(($NodesCount-1))); do
	RunBeacon $i
done

sleep 5

for i in $(seq 0 $(($NodesCount-1))); do
	RunValidator $i
done

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