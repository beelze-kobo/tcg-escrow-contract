# TCG Escrow Contract

This repository contains the smart contract for the TCG NFT Marketplace built on AnimeChain. The contract enables trustless peer-to-peer trading of ERC-1155 NFTs using the native ANIME token.

---

## 📜 Contract Overview

### `TCGmarketplace.sol`
- Allows sellers to list ERC-1155 NFTs with a fixed price in ANIME (native token).
- Buyers can purchase NFTs directly by paying the specified amount.
- Sellers can cancel listings.
- Funds are transferred directly from buyer to seller, and NFTs from seller to buyer upon purchase.

---

## 🛠 Tech Stack
- [Hardhat](https://hardhat.org/) – development environment
- Solidity ^0.8.20
- Deployed on: [AnimeChain]

---

## 🚀 Deploying Locally

```bash
npx hardhat compile
npx hardhat run scripts/deploy.js --network yourAnimeChainNetwork
