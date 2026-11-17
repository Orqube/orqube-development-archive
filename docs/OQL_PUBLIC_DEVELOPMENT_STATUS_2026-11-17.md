# ORQUBE OQL / Independent Blockchain — Public Development Status

Date: 2026-11-17 (KST)
Publication scope: public, non-secret technical status only.

ORQUBE is researching an independent programming language (OQL) and an independent blockchain, alongside wallet, mining, token/NFT, DEX, stablecoin and explorer components.

## Status of integrated development rounds 16–21
- A restricted Rust-based OQL compiler and virtual machine source has been extended with signed integer arithmetic and variable operands for addition, subtraction, multiplication, division and remainder.
- Prototype Rust host-side validation helpers were authored for transaction state changes, mining reward arithmetic, wallet preflight checks, token allocation, occupation identifiers, NFT ownership, DEX quote/slippage, stablecoin reserve-number checks, and explorer pagination.
- These are source-level prototypes, **not evidence of completed mainnet, audited consensus, operational financial reserves, deployed contracts or a production wallet integration**.
- Automated test cases were written, but compilation and execution have **not yet been verified** in the reported development environment.
- The original SASUM WALLET Build 22 must be preserved; integration with the prototype modules remains pending.

## Publication policy
- Public: high-level architecture, mathematical specifications, non-sensitive progress reports, verified milestones.
- Private: sensitive implementation details, security controls, operational settings, credentials, keys and unpublished code.
- No private keys, seed phrases, tokens, production credentials or unpublished proprietary source should be committed here.
