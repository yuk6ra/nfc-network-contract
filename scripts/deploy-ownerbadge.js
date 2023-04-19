const deploy = async () => {  
    const contractFactory = await ethers.getContractFactory("OwnerBadgeMock");

    const contract = await contractFactory.deploy();

    await contract.deployed();

    console.log("Contract Address: ", contract.address);
};

deploy();