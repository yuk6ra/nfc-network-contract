const { MerkleTree } = require("merkletreejs");
const keccak256 =  require("keccak256");
const { ethers } = require("hardhat");
const fs = require('fs')

const raw_data = fs.readFileSync('./assets/SecretNumber.json', 'utf8')
// const raw_data = fs.readFileSync('./assets/localnet_addresses.json', 'utf8')

let secretNumbers = JSON.parse(raw_data)

const leaves = secretNumbers.map(({ secretNumber }) =>
    ethers.utils.solidityKeccak256(
        ["bytes32"],
        [secretNumber]
    )
);

const merkleTree = new MerkleTree(leaves, keccak256, { sortPairs: true});

const rootHash = merkleTree.getRoot()


// console.log("Merkle Tree \n", merkleTree.toString());

for (let i=0; i < secretNumbers.length; i++ ) {
    console.log("==========", i, "==========")
    console.log("secretNumber\t:", secretNumbers[i].secretNumber);
    const addr = leaves[i]
    const hexProof = merkleTree.getHexProof(addr);
    console.log(`Proof\t: ["${hexProof.join('","')}"]`);
    console.log(`Proof\t: [${hexProof}]\n`);
}

console.log("========== Result ==========")
console.log("Root\t:", merkleTree.getHexRoot());

// node scripts/merkletree.js