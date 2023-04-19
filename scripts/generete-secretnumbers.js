const fs = require('fs');
const { ethers } = require("hardhat");

let data = [];

for (let i = 0; i < 10; i++) {
    let secretNumber = ethers.utils.solidityKeccak256(
        ["uint256"],
        [i]
    )
    data.push({secretNumber: secretNumber });
}

fs.writeFile('assets/SecretNumber.json', JSON.stringify(data), (err) => {
    if (err) throw err;
    console.log('Data written to file');
});