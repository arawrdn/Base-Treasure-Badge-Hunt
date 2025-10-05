# Base-Treasure-Badge-Hunt 🏆

Minimalist, self-contained ERC-721 contract for a 2-TX limited treasure hunt on Base. The winner gets an on-chain NFT badge!

---

## 🔍 Overview

This project implements a gas-efficient **"Guess the Secret"** challenge where each wallet is strictly restricted to a maximum of **two (2) transaction attempts** to prevent bots or transaction farming. The contract is designed as an **All-in-One** solution, combining both the Treasure Hunt logic and a basic **ERC-721 NFT Badge** implementation, requiring only a single deployment.

### Key Details

| Parameter | Value | Notes |
| :--- | :--- | :--- |
| **Chain** | Base Network | The contract is ready for Base deployment. |
| **Contract Address (CA)** | `0xb0A056f98988DB2C20b0cc655C1225F8094BA33D` | (Provided address) |
| **Correct Answer (Secret Input)** | `2025isMyYearForOnchainSuccess` | Must be an exact, case-sensitive match. |
| **NFT Badge Reward** | On-chain metadata: "2025 is for you" on a Yellow background. | Metadata is encoded directly in the contract (Data URI). |

---

## 🛠️ Owner Instructions (Deployment & Setup)

As the contract owner (deployer), your tasks are minimal due to the self-contained NFT design.

### 1. Deployment Requirements

You only need to deploy the single file, `TreasureBadgeSelfContained.sol`.

* **Solidity Pragma:** `0.8.30`
* **Optimization:** You **must** enable the optimizer during compilation to reduce deployment and transaction costs.
    ```bash
    solc --optimize --runs 200 TreasureBadgeSelfContained.sol
    ```
* **Action:** Deploy the resulting bytecode to the **Base** network.

### 2. Metadata Status

The NFT metadata is already fully encoded within the contract itself (using a Base64 Data URI). **No external server hosting (e.g., IPFS or AWS) is required.**

### 3. Distribute Clues

* **Action:** Announce the treasure hunt and provide clues that guide players to the correct secret: **`2025isMyYearForOnchainSuccess`**.

---

## 🎮 User Instructions (How to Win)

Users must call the single public function: `submitGuess(string memory userGuess)`.

### 1. Attempt Limits (Max 2 Attempts) ⚠️

Each wallet address is strictly limited to **two (2) transaction attempts** against the contract. This prevents bot spam and excessive transaction farming.

| Attempt Count | Guess Status | Transaction Result | Notes |
| :---: | :--- | :--- | :--- |
| **1st or 2nd** | Incorrect | **CONFIRMED (Success)** | Attempt is recorded. User pays Gas. No NFT. |
| **1st or 2nd** | **CORRECT** | **CONFIRMED (Success)** | **NFT is instantly minted to the wallet.** |
| **3rd and up** | Any | **REVERTS (Failed)** | Fails with the `MaxAttemptsReached` error. User pays Gas for the failed transaction. |

### 2. Winning Submission

To claim the NFT Badge, the user must call the function with the exact Secret Input:

```solidity
submitGuess("2025isMyYearForOnchainSuccess")
