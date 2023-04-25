#!/bin/bash

# they should start with 0x
validatoraddr=Your_Address_Here

# max 32 alpa and numbers
discordgrafiti=Your_Discord_Graffiti

function RunValidator() {
nohup lighthouse \
  vc \
  --testnet-dir "./consensus" \
  --datadir "./data/validator-data" \
  --suggested-fee-recipient="$validatoraddr" \
  --http-allow-origin="http://localhost:5062" \
  --metrics \
  --metrics-address 127.0.0.1 \
  --metrics-port 5062 \
  --logfile-compress \
  --graffiti "$discordgrafiti" \
  > ./logs/validator.log &
}

RunValidator