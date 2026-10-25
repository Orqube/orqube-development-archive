import solc from 'solc';import{readFileSync,writeFileSync}from 'node:fs';
const sources={'contracts/OrqubeToken.sol':{content:readFileSync('contracts/OrqubeToken.sol','utf8')}};
const input={language:'Solidity',sources,settings:{optimizer:{enabled:true,runs:200},evmVersion:'paris',outputSelection:{'*':{'*':['abi','evm.bytecode.object','evm.deployedBytecode.object','evm.deployedBytecode.immutableReferences','metadata']}}}};
function findImport(path){try{const content=readFileSync('node_modules/'+path,'utf8');sources[path]={content};return{contents:content}}catch{return{error:'Missing '+path}}}
const output=JSON.parse(solc.compile(JSON.stringify(input),{import:findImport}));if(output.errors?.some(e=>e.severity==='error'))throw Error(JSON.stringify(output.errors));
const c=output.contracts['contracts/OrqubeToken.sol'].OrqubeToken;
writeFileSync('public/polygon-artifact.json',JSON.stringify({compilerVersion:solc.version().split('.Emscripten')[0],contractIdentifier:'contracts/OrqubeToken.sol:OrqubeToken',stdJsonInput:input,abi:c.abi,bytecode:'0x'+c.evm.bytecode.object,runtimeBytecode:'0x'+c.evm.deployedBytecode.object,immutableReferences:c.evm.deployedBytecode.immutableReferences,metadata:JSON.parse(c.metadata)}));
console.log('Polygon artifact compiled; runtime bytes:',c.evm.deployedBytecode.object.length/2);
