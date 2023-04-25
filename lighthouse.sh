#!/bin/bash

#change other enr if static enr node cannot peers on your nodes
bootnodes=enr:-MS4QK6H6NKSHrkUIsWk-cKElY4z0nhavucTz3hVZXz4ZKqUW9FBOkun2Imr7mCGCeLuDACgTVY4-ePwafoodV58j8gHh2F0dG5ldHOIAAAAAAAAAACEZXRoMpCsQVpDAmd2k___________gmlkgnY0gmlwhJNLR9mJc2VjcDI1NmsxoQNGakDZReQblCjp6i_9ne0bqmmKEX6SSO52tbq458LgyYhzeW5jbmV0c4gAAAAAAAAAAIN0Y3CCIyiDdWRwgiMo,enr:-MS4QEhp9f3dY_SwD2kAJq1HTt76mJU1_Lv0KSdAcFHOdrpJSpqLmkB6kzPS6g8PPsfjnQftovh9DFiCsAwBgaKjHa4Hh2F0dG5ldHOIAAAAAAAAAACEZXRoMpCsQVpDAmd2k___________gmlkgnY0gmlwhJNLR9mJc2VjcDI1NmsxoQOFQuO5Eb-CyC_IauyClgQ1yadKxGHAd9FrUqHGrMc3u4hzeW5jbmV0c4gAAAAAAAAAAIN0Y3CCIymDdWRwgiMp
#they should start with 0x.
address=

function RunLighthouse() {
nohup lighthouse \
	  --testnet-dir "./consensus" \
	  bn \
	  --datadir "./data/consensus/lh-data" \
	  --eth1 \
	  --http \
	  --gui \
	  --http-allow-origin="*" \
	  --staking \
	  --execution-endpoints="http://localhost:8551" \
	  --eth1-endpoints="http://localhost:8545" \
	  --http-port=5052 \
	  --port=9000 \
	  --enr-udp-port=9000 \
	  --enr-tcp-port=9000 \
	  --discovery-port=9000 \
	  --logfile-max-number=5 \
	  --jwt-secrets="./data/execution/geth-data/geth/jwtsecret" \
	  --suggested-fee-recipient="$address" \
	  --boot-nodes="$bootnodes" \
	  > ./logs/beacon.log
}