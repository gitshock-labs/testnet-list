### Final
"Testnet Final: Cartenzswithdrawalsramid will be launched."

### How to Run? 

`Execution Layer on geth.sh`
discorduser = change with your username without series number (example: discorduser=parithoshj)

`Consensus Layer on lighthouse.sh` 
address = fill with your address validator [keep it safe or you can use eth2-val-tools to create a new mnemonic] (example: address=0x0000000000000000000000000000d34d)

### Setup Validator Deposit
`Setup Deposit & Withdrawal` 
smin= this is the minimal source validator that you will run, starting from 0 or 1 or according to your taste. (should not exceed the number set from source-max). Default: 0 
smax= if you want to run multiple validators (more than 64) the source-max section you can add numbers according to the tGTFX balance you have. Default: 1
wmnemonic= fill your mnemonic or you can generate new using eth2-val-tools to create a new mnemonic (example: eth2-val-tools mnemonic)
vmnemonic= fill your mnemonic or you can generate new using eth2-val-tools to create a new mnemonic (example: eth2-val-tools mnemonic)
address= address start with hexadecimal ( 0x )
privkey= private-key start with hexadecimal ( 0x )

`Validator Layer on validator.sh`
validatoraddr = change with your address from **Setup Validator Deposit** 
discordgrafiti = this is the validator identity of your node layer, you can use any word but must be coupled to no more than 32 words (example: discordgrafiti=Eth-Gitshock)

# Testnet Validator Channel
All Source Repository Testnet Eligible Node Validator Gitshock Finance &amp; Cosmos Network (Coming Soon)
This guide provides step-by-step instructions on how to participate as a validator on the testnet of the Ethereum and Cosmos networks. Before we get started, it's important to note that participating as a validator requires technical expertise, a good understanding of blockchain technology, and the ability to maintain server infrastructure. 

### Prerequisites
The recommended and officially supported operating system to host Gitshock Finance Nodes is Ubuntu 20.04 on a x86_64 compatible hardware. Although you can use Apple macOS or Microsoft Windows and other Nix flavors as well if you compile the node from the code code, currently only the official distribution can connect to the Gitshock Finance network.

1. A machine running a recent version of Ubuntu or another Linux distribution.
2. At least CPU 4 Core (2.1 Ghz or Above) 4GB of RAM (Recomended 8-16GB) and 250GB - 500GB of disk space.
3. Knowledge of execution layer of ethereum and consensus layer for eth2 beacon command line.
4. Basic understanding of Ethereum, including the difference between PoW and PoS consensus algorithms.
[Read Documents](https://docs.gitshock.com/developers/getting-started)

