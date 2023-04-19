const args = require("../args/args.js")

const deploy = async () => {  
    const contractFactory = await ethers.getContractFactory("FriendBadgeMock");

    const contract = await contractFactory.deploy(
        args[0]
    );

    await contract.deployed();

    console.log("Contract Address: ", contract.address);
};

deploy();