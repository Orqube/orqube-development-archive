// ORQUBE multichain browser bridge (testnets only).
// Solana dependencies are loaded only when the user selects Solana Devnet.
const SOLANA_RPC = 'https://api.devnet.solana.com';
let solanaModulesPromise;

function solanaProvider() {
  const p = window.solana;
  if (p && typeof p.connect === 'function' && typeof p.signTransaction === 'function') return p;
  if (window.phantom && window.phantom.solana) return window.phantom.solana;
  throw new Error('SOLANA_WALLET_NOT_FOUND');
}

async function solanaModules() {
  if (!solanaModulesPromise) {
    solanaModulesPromise = Promise.all([
      import('https://esm.sh/@solana/web3.js@1.98.4'),
      import('https://esm.sh/@solana/spl-token@0.4.14?deps=@solana/web3.js@1.98.4'),
    ]);
  }
  return solanaModulesPromise;
}

window.orqubeSolanaConnect = async () => {
  const provider = solanaProvider();
  const result = await provider.connect();
  const publicKey = result?.publicKey || provider.publicKey;
  if (!publicKey) throw new Error('SOLANA_ACCOUNT_REQUIRED');
  return {address: publicKey.toString(), chain: 'Solana'};
};

window.orqubeSolanaDeployMint = async (decimals, totalSupply) => {
  const provider = solanaProvider();
  await provider.connect();
  const walletKey = provider.publicKey;
  if (!walletKey) throw new Error('SOLANA_ACCOUNT_REQUIRED');

  const [web3, spl] = await solanaModules();
  const connection = new web3.Connection(SOLANA_RPC, 'confirmed');
  const mint = web3.Keypair.generate();
  const d = Number(decimals);
  if (!Number.isInteger(d) || d < 0 || d > 9) throw new Error('INVALID_DECIMALS');
  const supply = BigInt(String(totalSupply));
  if (supply <= 0n) throw new Error('INVALID_SUPPLY');

  const rent = await spl.getMinimumBalanceForRentExemptMint(connection);
  const ata = spl.getAssociatedTokenAddressSync(mint.publicKey, walletKey, false, spl.TOKEN_PROGRAM_ID, spl.ASSOCIATED_TOKEN_PROGRAM_ID);
  const tx = new web3.Transaction().add(
    web3.SystemProgram.createAccount({
      fromPubkey: walletKey,
      newAccountPubkey: mint.publicKey,
      space: spl.MINT_SIZE,
      lamports: rent,
      programId: spl.TOKEN_PROGRAM_ID,
    }),
    spl.createInitializeMintInstruction(mint.publicKey, d, walletKey, walletKey, spl.TOKEN_PROGRAM_ID),
    spl.createAssociatedTokenAccountInstruction(walletKey, ata, walletKey, mint.publicKey, spl.TOKEN_PROGRAM_ID, spl.ASSOCIATED_TOKEN_PROGRAM_ID),
    spl.createMintToInstruction(mint.publicKey, ata, walletKey, supply * (10n ** BigInt(d)), [], spl.TOKEN_PROGRAM_ID),
  );
  tx.feePayer = walletKey;
  const latest = await connection.getLatestBlockhash('confirmed');
  tx.recentBlockhash = latest.blockhash;
  tx.partialSign(mint);
  const signed = await provider.signTransaction(tx);
  const signature = await connection.sendRawTransaction(signed.serialize(), {skipPreflight: false, maxRetries: 3});
  await connection.confirmTransaction({signature, blockhash: latest.blockhash, lastValidBlockHeight: latest.lastValidBlockHeight}, 'confirmed');
  return {address: mint.publicKey.toString(), txHash: signature, chain: 'Solana'};
};
