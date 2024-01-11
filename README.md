
## Trust Score Smart Contract Developement

## Goal
The primary objective of this stage is to develop a smart contract capable of autonomously computing a trust score for each Contract Service Provider (CSP).
## Tools Used
## Ethereum
Ethereum serves as the foundational blockchain platform, enabling the creation and execution of smart contracts. This decentralized exchange protocol forms the basis for our trust score smart contract.

## MetaMask
MetaMask, a crucial cryptocurrency software wallet, is essential for interacting with the Ethereum blockchain. Its browser extensions or mobile apps provide users with access to their Ethereum wallets, facilitating seamless interaction with decentralized applications, including our trust score smart contract.

## thirdweb
thirdweb plays a vital role in our development process. Leveraging its capabilities, we enhance the functionality and deployment of our smart contract, ensuring efficiency in the blockchain ecosystem.

## Hardhat
Hardhat is a development environment for Ethereum that streamlines the building and testing of smart contracts. It simplifies the development process, making it easier to write, test, and deploy smart contracts.

## Solidity
Solidity, a programming language specifically designed for smart contracts, is utilized to code the logic of the trust score computation in our contract. It ensures the secure and efficient execution of the smart contract on the Ethereum blockchain.

## Next Steps
Our development process involves using Hardhat for testing, Solidity for smart contract coding, MetaMask for wallet interaction, and thirdweb for deployment and enhancement. The subsequent phase will include rigorous testing, followed by the deployment of the trust score smart contract on the Ethereum blockchain.
   
   
   
## Getting Started

Create a project using this example:

```bash
npx thirdweb create --contract --template forge-starter
```

You can start editing the page by modifying `contracts/Contract.sol`.

To add functionality to your contracts, you can use the `@thirdweb-dev/contracts` package which provides base contracts and extensions to inherit. The package is already installed with this project. Head to our [Contracts Extensions Docs](https://portal.thirdweb.com/thirdweb-deploy/contract-extensions) to learn more.

## Building the project

After any changes to the contract, run:

```bash
npm run build
# or
yarn build
```

to compile your contracts. This will also detect the [Contracts Extensions Docs](https://portal.thirdweb.com/thirdweb-deploy/contract-extensions) detected on your contract.

## Deploying Contracts

When you're ready to deploy your contracts, just run one of the following command to deploy you're contracts:

```bash
npm run deploy
# or
yarn deploy
```

## Releasing Contracts

If you want to release a version of your contracts publicly, you can use one of the followings command:

```bash
npm run release
# or
yarn release
```

