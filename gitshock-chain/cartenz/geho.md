### Tutorial Menjalankan Validator GETH - LIGHTHOUSE

Membangun Akun Eksekusi Layer Baru Menggunakan Command: 
geth account new --datadir "/path/folder/akun/anda" 

> Simpan Public & Keystore anda dengan Aman!

Membangun Custom Genesis Block Baru Menggunakan Command: 
geth --datadir "/path/folder/akun/anda" init /path/folder/berisi/genesis.json

## Menjalankan Eksekusi Layer Milik Anda: 
nohup geth \
--http \
--http.addr 0.0.0.0 \
--http.api=eth,net,web3,personal,miner,admin \
--http.port 8545 \
--ws \
--ws.addr 0.0.0.0 \
--ws.api=eth,net,web3,personal,miner,admin \
--ws.port 8546 \
--http.vhosts=* \
--http.corsdomain=* \
--networkid 1881 \
--datadir "data" \
--authrpc.port 8551 \
--port 30303 \
--metrics \
--metrics.addr 0.0.0.0 \
--metrics.port 6060 \
--verbosity 3 \
--pprof \
--pprof.addr 0.0.0.0 \
--syncmode full \
--cache 1024 \
--light.maxpeers 10 \
--gpo.blocks 20 \
--gpo.ignoreprice 2 \
--gpo.maxprice 500000000000 \
--gcmode="archive" \
--bloomfilter.size 2048 \
--rpc.gascap 50000000 \
--rpc.txfeecap 1 \
--graphql \
--graphql.corsdomain=* \
--graphql.vhosts=* \
--authrpc.jwtsecret /root/testnet-list/eth-network/jwt.hex \
> /root/testnet-list/eth-network/logs/geth_1.log &

## Menambahkan Peer Node Blockchain Cartenz Menggunakan Command: 
geth attach http://localhost:8545 

Setelah Masuk Kedalam Interaktif Console Geth, Anda Harus Menambahkan Manual Peer & Trusted Peer Minimal 1 Untuk Terkoneksi Dengan Blockchain Dibawah Ini Adalah List Peer Yang Anda Boleh Pilih:
enode://a478d3309e0dc1deb0e2a62e0b892e0d6d931b5dbf83d75c3811d48aa2d814b645567270b6ca220a34c0b9b417def6d5a6ea084dfa1e50e79f20a1808640e710@147.75.71.217:30303
enode://de68503ed3aa6980fe38834c61be0e2b39e2291e9989e24f308904cbf8c0fb2864d30d5a814dda44aac1fe0626266864a9aa2d6a9f9e1635553c374ed75bb6cd@147.75.71.217:30304
enode://03fc89e2035b52a609715a15dacad4179f57c0b1e51b3464a931f0fa913b9169d06df1b23515f41e4ed6d9be0e50f33175cbf836e7b6738c62eee00ad45250b0@212.47.241.173:30303

## Mendapatkan Bootnode Didalam Interaktif Console Geth, Untuk Anda Simpan Menggunakan Command: 
admin.nodeInfo.enode

Contoh Output: 
"enode://03fc89e2035b52a609715a15dacad4179f57c0b1e51b3464a931f0fa913b9169d06df1b23515f41e4ed6d9be0e50f33175cbf836e7b6738c62eee00ad45250b0@212.47.241.173:30303"

## Menjalankan Consensus Layer Milik Anda: 
nohup lighthouse beacon \
--http \
--eth1 \
--reset-payload-statuses \
--subscribe-all-subnets \
--validator-monitor-auto \
--enable-private-discovery \
--staking \
--testnet-dir /root/testnet-list/eth-network/cartenz/consensus \
--datadir "/root/testnet-list/eth-network/beacons" \
--eth1-endpoints "http://127.0.0.1:8545" \
--execution-endpoint "http://127.0.0.1:8551" \
--execution-jwt "/root/testnet-list/eth-network/jwt.hex" \
--http-allow-origin "*" \
--gui \
--enr-address 212.47.241.173 \
--http-address 0.0.0.0 \
--http-port 5052 \
--enr-udp-port 9000 \
--enr-tcp-port 9000 \
--port 9000 \
--disable-packet-filter \
--graffiti "UBAH SAYA DENGAN NAMA UNIK ANDA" \
> /root/testnet-list/eth-network/logs/validator_1.log &

## Mendapatkan ENR Milik Anda:
curl http://localhost:5052/eth/v1/node/identity | jq 

## Menjalankan Consensus Layer Kedua Milik Anda: 
nohup lighthouse beacon \
--http \
--eth1 \
--reset-payload-statuses \
--subscribe-all-subnets \
--validator-monitor-auto \
--enable-private-discovery \
--staking \
--testnet-dir /root/testnet-list/eth-network/cartenz/consensus \
--datadir "/root/testnet-list/eth-network/beacons1" \
--eth1-endpoints "http://127.0.0.1:8545" \
--execution-endpoint "http://127.0.0.1:8551" \
--execution-jwt "/root/testnet-list/eth-network/jwt.hex" \
--http-allow-origin "*" \
--gui \
--enr-address 212.47.241.173 \
--http-address 0.0.0.0 \
--http-port 5053 \
--enr-udp-port 9001 \
--enr-tcp-port 9001 \
--port 9001 \
--disable-packet-filter \
--graffiti "UBAH SAYA DENGAN NAMA UNIK ANDA" \
--boot-nodes="ISI DENGAN ENR YANG SUDAH ANDA DAPAT DARI CONSENSUS LAYER PERTAMA DAN TAMBAHKAN DARI ENR CARTENZ CHAIN" \
> /root/testnet-list/eth-network/logs/validator_2.log &

> Perhatian! ENR Key Ada Di Dalam Folder consensus/bootnode_enr.txt

## Membangun Staker Untuk Menjadi Validator Baik Milik Anda: 
Kunjungi Laman Website Staking Dan Pilih Deposit Lalu Lakukan Deposit Dengan Command: 
deposit new-mnemonic --num_validators 8 --eth1_withdrawal_address 0x9adddA86C9479C45bD145BBa9FC28146FdF46C83

Contoh Output : "vibrant refuse observe flag shy depth disagree proud race angle vote picnic fancy renew museum bonus arena people thumb there atom tuna abstract negative"

> Simpan Mnemonic Anda Dengan Aman!

Menjalankan Import Key Milik Anda:
lighthouse account validator import \
--testnet-dir /root/testnet-list/eth-network/cartenz/consensus \
--datadir "/root/testnet-list/eth-network/validator" \
--directory /root/testnet-list/eth-network/validator_keys \
--password-file /root/testnet-list/eth-network/validator_keys/password.txt \
--reuse-password

## Menjalankan Validator Staker Milik Anda:
nohup lighthouse vc \
--suggested-fee-recipient 0x9adddA86C9479C45bD145BBa9FC28146FdF46C83 \
--metrics-address 0.0.0.0 \
--metrics-allow-origin "*" \
--metrics-port 8801 \
--http-allow-origin "*" \
--http-address 0.0.0.0 \
--http \
--unencrypted-http-transport \
--graffiti "ChibaFork" \
--testnet-dir "/root/testnet-list/eth-network/cartenz/consensus" \
--datadir "/root/testnet-list/eth-network/validator" \
--beacon-nodes "http://127.0.0.1:5052" \
> /root/testnet-list/eth-network/logs/validator_run.log &
