# Independent chain: v0.9 post-quantum signature laboratory

The v0.9 local prototype adds mandatory ML-DSA-65 transaction signatures using PyCA cryptography 50.0.2. This is a separate experimental network, not a production deployment or an update to the public explorer.

## Implemented

- Separate network identity, genesis, and default data directory; legacy ledger files are rejected without overwriting them.
- ML-DSA-65 is required for every transaction input. There is no ECDSA fallback or hybrid mode in this version.
- Signed transaction bodies bind the network, explicit algorithm identifier, all inputs and outputs; an application context separates transaction signatures from other uses.
- Canonical public key/signature encodings and length checks; legacy owners and unsupported algorithms are rejected.
- Ownership uses a prefixed full public key identifier. A compact, checksum-protected address and production wallet are future work.

## Validation

The v0.8 baseline passed 58 tests. The adapted v0.9 regression suite and 12 additional PQ tests passed 70 tests, including signature mutation/omission, downgrade rejection, wrong contexts/networks, double spending, immutable rejection, persistence, reorganization, local peer synchronization, and refusal to overwrite legacy data.

## Release boundaries

No real assets were migrated, no public network was launched, and no live website was updated. Source distribution remains separate from this public status document; no private issuance parameters or signing keys are published here. The earlier proposal's optional hybrid mode is not implemented. Official known-answer-vector testing, independent interoperability validation, secure wallet/key custody, resource/performance evaluation, and external audit remain required before any production release. These integration results are not NIST certification or a guarantee of quantum security. The prototype's PoW, hashing, and remaining consensus rules have not been redesigned or certified for quantum resistance.

References: [NIST FIPS 204](https://csrc.nist.gov/pubs/fips/204/final), [PyCA ML-DSA documentation](https://cryptography.io/en/stable/hazmat/primitives/asymmetric/mldsa/).
