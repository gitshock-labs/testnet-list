### EVM Products
Gitshock Circle Chain solves the virtual machine security problem by fully trusting the EVM (Ethereum Virtual Machine) from the official Go-Ethereum codebase.

The EVM is a well-tested product used by the entire blockchain community and has been audited thousands of times. Circle Chain Gitshock does not rely on third-party services that can manage staking and governance. Instead, it implements all the special staking and governance logic right in the smart contracts. This means that staking, governance, and reward distribution are fully managed and verified by the EVM runtime environment.

### On-Chain Security
Everything that happens on Circle Chain Gitshock is controlled by the governance model: from blockchain consensus, proposal changes, to staking.

### Governance
On-chain governance helps to solve important consensus questions, such as upgrading the runtime, increasing the validator set, or adjusting blockchain parameters. By selecting honest validators, users also distribute voting power among validators in on-chain governance.

### Proposal Changes
Users can propose changes, including governance changes. Each proposal is reviewed and chosen by other Circle Chain users. Only after reaching the quorum, governance proposals can be implemented.

Here is a list of proposals available on Circle Chain:

- Add or remove validators from the validator set
- Manage blockchain parameters
- Gas Limit Settings
- Available Consensus Protocols: (POS & POA)
- Number of active validators
- Block time interval
- Threshold of violation
- Threshold of malfeasance
- Delegation cancellation period where claim funds are not available
- Minimum validator stake amount
- Minimum betting amount
- Upgrade existing runtime or use a new smart contract system

### Staking
We want Gitshock Circle Chain to be as decentralized as possible, so while validators on the network produce blocks, other validators verify these blocks.
Validators are incentivized to perform positively and negatively. Validators who optimize their environment get bigger rewards and lower commission rates. In turn, they are more frequently chosen by users. However, if a validator performs poorly, they get fewer rewards at stake and are less frequently chosen by users. And if a validator misses one block, they can be punished or even slashed and jailed for 1 week for poor performance.

In addition to these factors, validators on the Circle Chain Gitshock network are also incentivized in the following ways:

- A well-configured network allows them to get more transactions in the pool and, as a result, increase APY.
- Better CPUs allow for more transactions to be included in a block.
- Every missed block results in a loss of rewards, and transactions in it go to the next validator.
- Repeated block errors can lead to the validator being punished and losing rewards for 1 epoch, which is usually 1 day.
- Poor-performing validators are jailed for 1 week and lose 1/4 of their monthly rewards.
- Invalid or dangerous blocks are rejected by honest validators, indirectly causing poor validators to lose rewards.
- End-to-End Donation-Based dApp Crowdfunding on Polygon with Ankr.