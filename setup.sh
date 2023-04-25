#!/bin/bash

echo "
█▀ █▀▀ ▀█▀ █░█ █▀█   █▀▀ ▄▀█ █▀█ ▀█▀ █▀▀ █▄░█ ▀█   █▀▀ █░█ ▄▀█ █ █▄░█
▄█ ██▄ ░█░ █▄█ █▀▀   █▄▄ █▀█ █▀▄ ░█░ ██▄ █░▀█ █▄   █▄▄ █▀█ █▀█ █ █░▀█"
echo .......
setup_eth2valtools() {
  # install eth2-val-tools
  sudo apt install gcc -y
  go install github.com/protolambda/eth2-val-tools@latest
  sudo cp ~/go/bin/eth2-val-tools /usr/local/bin
  echo "Installing Genesis Eth2ValTools"
}

setup_etherealdo() {
    # install ethereal-do
    wget https://github.com/wealdtech/ethereal/releases/download/v2.8.7/ethereal-2.8.7-linux-amd64.tar.gz
    tar -xvf ethereal-2.8.7-linux-amd64.tar.gz
    sudo cp ethereal /usr/local/bin
}

setup_eth2valtools
setup_etherealdo