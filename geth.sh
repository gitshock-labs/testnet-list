#!/bin/bash

# change with other static bootnodes if this bootnodes cannot connect to your nodes
bootnodes=enode://d66b72f069941d57ede5ed1af3988b9d776118cb1afa88a2f7635b34c9a43aa80efd2a57186a21459245bf43af54f9729db4d7c8f9d3951971182f081454a0b9@147.75.71.217:30303
#add your discord user (example=parithoshj)
discorduser=Your_Discord_User
######## Checker Functions

function CheckGeth()
{
	Log "Checking Your Geth Node"
	test -z $my_ip && my_ip=`curl ifconfig.me 2>/dev/null` && Log "my_ip=$my_ip"
	geth attach --exec "admin.nodeInfo.enode" data/execution/geth-data/geth.ipc | sed s/^\"// | sed s/\"$//
	echo Peers: `geth attach --exec "admin.peers" data/execution/geth-data/geth.ipc | grep "remoteAddress" | grep -e $my_ip -e "127.0.0.1"`
	echo Block Number: `geth attach --exec "eth.blockNumber" data/execution/geth-data/geth.ipc`
}
function KillAll() {
	Log "Kill All Apps"
	killall geth beacon-chain validator
	pkill -f ./prysm.*
	pkill -f lodestar.js
    pkill -f lighthouse
    pkill -f erigon
}

function InitGeth()
{
	Log "Initializing geth"
	geth init \
	  --datadir "./data/execution/geth-data" \
	  ./execution/genesis.json
}
function RunGeth() {
nohup geth \
		--http \
		--http.port 8545 \
		--http.api=eth,net,admin \
		--http.addr=127.0.0.1 \
		--bloomfilter.size 2048 \
		--gcmode=archive \
		--identity "$discorduser" \
		--log.rotate \
		--log.compress \
		--log.debug \
        --log.maxsize 100 \
		--log.maxage 5 \
		--log.maxbackups 10 \
		--log.vmodule "eth/*3, p2p=3" \
		--verbosity 3 \
		--http.vhosts=* \
		--http.corsdomain=* \
		--cache 1024 \
		--cache.blocklogs 32 \
		--cache.database 50 \
		--cache.gc 25 \
		--cache.trie 15 \
		--txpool.globalslots 5120 \
		--networkid 1881 \
		--ethstats "cartenzverkle:nodephase1@127.0.0.1:5555" \
		--datadir "./data/execution/geth-data" \
		--maxpeers 50 \
		--authrpc.port 8551 \
		--port 30303 \
		--discovery.port 30303 \
		--syncmode light \
        --bootnodes=$bootnodes \
		> ./logs/geth.log &
        sleep 5 # Set to 5 seconds to allow the geth to bind to the external IP before reading enode
        #local variablename="bootnode_geth_$1"
        #export $variablename=`geth attach --exec "admin.nodeInfo.enode" data/execution/$1/geth.ipc | sed s/^\"// | sed s/\"$//`
        #Log "$variablename = ${!variablename}"
        #echo ${!variablename} >> execution/bootnodes.txt
        local my_enode=$(geth attach --exec "admin.nodeInfo.enode" data/execution/geth-data/geth.ipc | sed s/^\"// | sed s/\"$// | sed s/'127.0.0.1'/$my_ip/)
	    echo $my_enode >> data/execution/geth-data/bootnodes.txt
}


CheckGeth
KillAll
InitGeth
RunGeth