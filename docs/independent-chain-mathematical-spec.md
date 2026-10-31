# ORQUBE Independent Chain — Mathematical State Transitions and Validation Rules

ORQUBE Foundation · 2026-10-31  
Scope: independent experimental PoW node v0.5  
[Node configuration and three-node test record](https://github.com/Orqube/orqube-development-archive/issues/2)

This document expresses the operations of the available v0.5 implementation mathematically. It proposes neither a new cryptographic algorithm nor a security proof. Private issuance and allocation parameters are omitted. Implemented behavior and future concepts are distinguished. Test results below refer to the previously recorded 2026-10-31 execution; this language revision does not constitute a new test run.

## 1. Notation and state

| Symbol | Meaning |
|---|---|
| $B_h$ | Block at height $h$ |
| $C_h=(B_0,\ldots,B_h)$ | Chain beginning at genesis |
| $U_h$ | Unspent transaction output set after height $h$ |
| $S_h$ | Cumulative newly issued quantity through height $h$ |
| $H(x)$ | $\mathrm{SHA256}(\mathrm{SHA256}(x))$ |
| $E(x)$ | Canonical JSON byte serialization used by the code |
| $R(x)$ | Byte-order reversal |
| $b_h$ | Compact target field, bits |
| $T(b_h)$ | Decoded proof-of-work target |
| $\Phi$ | State transition applying a validated block |

$$
(U_h,S_h)=\Phi(U_{h-1},S_{h-1},B_h)
$$

If validation fails, $\Phi$ is undefined and the block is not adopted. This expression describes the result; execution and persistence ordering are specified below.

## 2. Block header and hash

The header concatenates six byte fields:

$$
\mathrm{hdr}(B_h)=
\mathrm{LE}_{32}(v_h)
\Vert R(\mathrm{hexDecode}(p_h))
\Vert R(\mathrm{hexDecode}(m_h))
\Vert \mathrm{LE}_{32}(t_h)
\Vert \mathrm{LE}_{32}(b_h)
\Vert \mathrm{LE}_{32}(n_h)
$$

$$
|\mathrm{hdr}(B_h)|=4+32+32+4+4+4=80\ \mathrm{bytes}
$$

Here $v_h$ is the version, $p_h$ the previous block hash, $m_h$ the Merkle root, $t_h$ the timestamp, and $n_h$ the nonce. Integer fields are unsigned 32-bit integers; booleans are rejected.

The displayed block identifier is:

$$
\mathrm{id}(B_h)=\mathrm{hex}\!\left(R(H(\mathrm{hdr}(B_h)))\right)
$$

Linkage requires:

$$
p_h=\mathrm{id}(B_{h-1}),\qquad h=h_{\mathrm{prev}}+1
$$

The byte ordering and integer interpretation must match these serialization rules.

## 3. Proof of work and nonce search

Decode the exponent and coefficient:

$$
e=b\gg24,\qquad c=b\mathbin{\&}\mathtt{0x007fffff}
$$

$$
T(b)=
\begin{cases}
c\gg 8(3-e),&e\le3\\
c\ll 8(e-3),&e>3
\end{cases}
$$

The sign bit, a zero coefficient, and targets outside $(0,2^{256})$ are rejected. The current node rejects bits values different from its fixed experimental setting.

$$
y_h=\mathrm{int}_{16}(\mathrm{id}(B_h))
$$

$$
\boxed{y_h\le T(b_h)}
$$

The implementation uses an inclusive comparison. Assuming uniform, independent hash outputs:

$$
P(\mathrm{success})=\frac{T+1}{2^{256}},\qquad
\mathbb{E}[N]=\frac{2^{256}}{T+1}
$$

Nonce search is restricted to $0\le n\le2^{32}-1$. The expectation models computational work; it does not guarantee block production within a fixed time.

## 4. Merkle commitment to transactions and signatures

The reward description contains the network, height, recipient public key, and reward amount.

$$
q_0=\mathrm{hex}(H(E(\mathrm{coinbaseDescription}_h)))
$$

The remaining leaves hash complete transactions, including signatures:

$$
q_j=\mathrm{hex}(H(E(tx_j))),\qquad j=1,\ldots,k
$$

Convert leaves to internal byte order, then combine adjacent nodes:

$$
L_j^{(0)}=R(\mathrm{hexDecode}(q_j))
$$

$$
L_j^{(r+1)}=H\!\left(L_{2j}^{(r)}\Vert L_{2j+1}^{(r)}\right)
$$

Duplicate the last node when a level has an odd number of nodes. Reverse the final root for hexadecimal display:

$$
m_h=\mathrm{hex}(R(L_0^{(\mathrm{last})}))
$$

Validation recomputes the root from the body and compares it with the header. Transaction reference IDs exclude signatures, but the block's Merkle commitment includes all signatures.

## 5. Ownership and signature verification

The signed transaction body contains:

$$
M_{tx}=E(\{\mathrm{network},\mathrm{inputs},\mathrm{outputs}\})
$$

For the public key $Q_i$ owning the UTXO referenced by input $i$:

$$
\mathrm{Verify}_{Q_i}^{\mathrm{ECDSA/SHA256}}
(M_{tx},\sigma_i)=\mathrm{true}
$$

The current curve is secp256k1. Public keys must satisfy the implementation's compressed encoding and valid-curve-point checks.

The transaction reference identifier is:

$$
\mathrm{txid}=\mathrm{hex}(H(M_{tx}))
$$

The signature count must equal the input count, and the network identifier must match the experimental network. This implementation does not use post-quantum signatures.

## 6. UTXOs and quantity conservation

Let $I$ be the set of input references and $O$ the output list.

$$
I\subseteq\mathrm{dom}(U),\qquad |I|=\text{input list length}
$$

These conditions reject missing or spent outputs and duplicate inputs, respectively.

$$
V_{\mathrm{in}}=\sum_{i\in I}U[i].\mathrm{amount}
$$

$$
V_{\mathrm{out}}=\sum_{o\in O}o.\mathrm{amount}
$$

$$
V_{\mathrm{out}}\le V_{\mathrm{in}},\qquad
f_{tx}=V_{\mathrm{in}}-V_{\mathrm{out}}\ge0
$$

Each output amount is a positive integer within the allowed range. Floating-point amounts and booleans are rejected.

$$
U'=(U\setminus I)\cup
\{(\mathrm{txid}:j)\mapsto O_j\}
$$

Experimental reward outputs also require maturity:

$$
h-h_{\mathrm{created}}\ge M_{\mathrm{lab}},
\qquad M_{\mathrm{lab}}=2
$$

This is a local test parameter. Rejected transactions do not mutate the caller's UTXO state.

## 7. Block rewards and cumulative issuance

Private issuance parameters are represented symbolically. The existing integer reduction function can be written as:

$$
s(h,S)=
\min\!\left(
\left\lfloor\frac{A}{2^{\lfloor(h-1)/J\rfloor}}\right\rfloor,
C_{\max}-S
\right)
$$

$A$ is the initial unit reward, $J$ the reduction interval, and $C_{\max}$ the design cap. These symbols abstract the existing experimental function; they do not establish a new policy.

$$
F_h=\sum_{tx\in B_h}f_{tx}
$$

$$
r_h=s(h,S_{h-1})+F_h
$$

$$
S_h=S_{h-1}+s(h,S_{h-1})
$$

Fees transfer existing quantity and are not counted again as new issuance. Integer flooring means the cap need not be reached exactly. This document does not finalize a mainnet issuance schedule.

## 8. Timestamp validation

Let $A_h$ contain the timestamps of up to 11 preceding blocks. For an even number of elements, the code selects the upper middle element:

$$
\mathrm{MTP}_h=\mathrm{sort}(A_h)_{\lfloor |A_h|/2\rfloor}
$$

$$
t_h>\mathrm{MTP}_h,\qquad
t_h\le t_{\mathrm{local}}+7200
$$

Future-time rejection depends on the validating node's clock. A block rejected now may become acceptable later. These checks do not constitute complete protection against time-synchronization attacks.

## 9. Cumulative work and chain selection

The per-block expected-work indicator is:

$$
w(B_h)=\left\lfloor\frac{2^{256}}{T(b_h)+1}\right\rfloor
$$

Cumulative work excludes genesis:

$$
W(C)=\sum_{h=1}^{H}w(B_h)
$$

For current chain $C$ and candidate $C'$:

$$
\mathrm{Adopt}(C')=
\mathrm{Valid}(C')\land[W(C')>W(C)]
$$

$$
W(C')=W(C)\ \Longrightarrow\ \text{retain the current chain}
$$

With a fixed target, cumulative work is proportional to the number of valid additional blocks. It is neither measured energy use nor the observed number of hash attempts.

A replacement chain is replayed from genesis:

$$
(U',S')=\mathrm{Replay}(C')
$$

Rewards and transaction effects from discarded branches therefore do not remain in the adopted ledger.

## 10. Atomic persistence and revalidation

For state $(C,U,S)$, a candidate is validated and saved before the in-memory state changes:

$$
\mathrm{Validate}(C')
\rightarrow\mathrm{WriteTemp}(C')
\rightarrow\mathrm{Flush/Fsync}
\rightarrow\mathrm{Replace}
\rightarrow C\gets C'
$$

Automated tests checked preservation of existing state on save failure. Restart revalidates the stored chain; a damaged file is not automatically overwritten with an empty ledger. An operating-system lock rejects concurrent writers to one data directory. This does not prove losslessness under every hardware or filesystem failure.

## 11. Three-node state convergence

Let $C_A,C_B,C_C$ be the chains held by nodes A, B, and C. In the recorded test, B periodically queried A and C queried B:

$$
B\leftarrow A,\qquad C\leftarrow B
$$

The comparison checked height, tip hash, and cumulative work:

$$
h_A=h_B=h_C
$$

$$
\mathrm{tip}(C_A)=\mathrm{tip}(C_B)=\mathrm{tip}(C_C)
$$

$$
W(C_A)=W(C_B)=W(C_C)
$$

The 2026-10-31 local run recorded initial synchronization at height 3, convergence at height 5 after restarting A and adding blocks, and persistence after individual restarts of B and C. These were three processes on one PC. The equalities describe that test's agreement criteria, not a theorem guaranteeing convergence under arbitrary failures or adversarial networks.

## 12. ORQUBE participation linkage — future concept

Verified participation histories of existing ORQUBE miners are intended to motivate future independent-chain participation:

$$
\mathrm{VerifiedHistory}_i
\longrightarrow
\mathrm{EligibilityReview}_i
\longrightarrow
\mathrm{FutureParticipation}_i
$$

Eligibility and linkage conditions remain undecided. This concept is not applied to current consensus, issuance, or signature validation. It does not establish automatic conversion, distribution, or an exchange ratio.

## 13. Implementation and verification mapping

| Mathematical rule | Implementation | Recorded verification scope |
|---|---|---|
| Header, target, Merkle root | headers.py | Hash vectors, target decoding, tampering checks |
| Basic reward function | chain.py | Integer rewards, cap, persistence and reload |
| Signatures, UTXOs, replay | ledger.py | Transfers, fees, double spending, branch reconstruction |
| Candidate adoption, persistence, synchronization | node.py | HTTP synchronization, restart, invalid candidate rejection |
| Two-process checks | check_pc.py | Five checks in the existing report |
| Three-process checks | Separate temporary execution | Local convergence and restart on 2026-10-31 |

The preceding verification record reports that all 46 v0.5 automated tests passed when rerun on 2026-10-31. Mathematical documentation is not an additional security certification or deployment of new node functionality. Public P2P networking, dynamic difficulty, a mempool, production wallets, ASIC connectivity, and post-quantum migration require separate implementation and validation.
