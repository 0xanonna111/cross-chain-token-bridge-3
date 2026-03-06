# Cross-Chain Token Bridge

A streamlined, flat-structure repository for a cross-chain bridging protocol. This system utilizes a "Lock/Unlock" mechanism on the home chain and a "Mint/Burn" mechanism on the shadow chain.

## Bridge Architecture
* **Source Chain (Locking)**: Users deposit native ERC20 tokens into the `BridgeVault`.
* **Destination Chain (Minting)**: An authorized relayer or validator provides a cryptographic signature to mint equivalent `WrappedToken` units.
* **Security**: Includes nonces to prevent replay attacks and a multi-signature requirement for validator updates.



## Workflow
1. **Deposit**: User calls `lock()` on Chain A.
2. **Attestation**: Off-chain relayers detect the `Locked` event and sign a message.
3. **Claim**: User (or relayer) calls `mint()` on Chain B with the signature.
4. **Exit**: To return, the user calls `burn()` on Chain B and `unlock()` on Chain A.

## Tech Stack
* Solidity ^0.8.20
* OpenZeppelin ECDSA & Cryptography
* Hardhat
