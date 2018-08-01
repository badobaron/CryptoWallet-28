const path = require('path');
const solc = require('solc');
const fs = require('fs-extra');

const buildPath = path.resolve(__dirname, 'build');

// Delete build folder
fs.removeSync(buildPath);

// Read contents of Campaign.sol file
const walletPath = path.resolve(__dirname, 'contracts', 'CryptoWallet.sol');
const source = fs.readFileSync(walletPath, 'utf8');

// Compile both contracts with solc
const output = solc.compile(source, 1).contracts;

//Write output to build directory
fs.ensureDirSync(buildPath);

for(let contract in output) {
  fs.outputJsonSync(
    path.resolve(buildPath, contract.replace(':', '') + '.json'),output[contract]
  );
}
