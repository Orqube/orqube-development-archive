// Uses the solc 0.8.30 package already supplied by functions_ai.
const fs = require('fs');
const path = require('path');
const solc = require('../../functions_ai/node_modules/solc');
const root = path.resolve(__dirname, '..');
const sources = {};
for (const name of ['src/OrqubeStaking.sol', 'test/OrqubeStaking.t.sol'])
  sources[name] = {content: fs.readFileSync(path.join(root,name),'utf8')};
const settings = {optimizer:{enabled:true,runs:200},evmVersion:'paris',outputSelection:{'*':{'*':['abi','evm.bytecode.object']}}};
const output = JSON.parse(solc.compile(JSON.stringify({language:'Solidity',sources,settings})));
for (const error of output.errors || []) console.log(error.formattedMessage);
if ((output.errors || []).some(e=>e.severity==='error')) process.exit(1);
fs.mkdirSync(path.join(root,'artifacts'),{recursive:true});
const contract = output.contracts['src/OrqubeStaking.sol'].OrqubeStaking;
fs.writeFileSync(path.join(root,'artifacts/OrqubeStaking.abi.json'),JSON.stringify(contract.abi,null,2));
fs.writeFileSync(path.join(root,'artifacts/OrqubeStaking.bytecode.txt'), '0x'+contract.evm.bytecode.object+'\n');
fs.writeFileSync(path.join(root,'artifacts/compiler-settings.json'),JSON.stringify({compiler:solc.version(),...settings},null,2));
console.log('Compiled staking contract and test suite. Tests must be executed with forge test.');
