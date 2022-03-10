const main = async () => {
  const [owner, randomPerson] = await hre.ethers.getSigners();
  const bbContractFactory = await hre.ethers.getContractFactory(
    "ByteBeatPortal"
  );
  const bbContract = await bbContractFactory.deploy({
    value: hre.ethers.utils.parseEther("0.1"),
  });
  await bbContract.deployed();

  let contractBalance = await hre.ethers.provider.getBalance(
    bbContract.address
  );
  console.log(
    "Contract balance:",
    hre.ethers.utils.formatEther(contractBalance)
  );

  console.log("Contract deployed to:", bbContract.address);
  console.log("Contract deployed by:", owner.address);

  let bbTxn = await bbContract.addFormula("t*t");
  await bbTxn.wait();

  bbTxn = await bbContract.connect(randomPerson).addFormula("t>>256");
  await bbTxn.wait();

  let formulas = await bbContract.getFormulas();
  formulas.map((formula, index) => {
    console.log("formula no%d: %s", index, formula);
  });

  contractBalance = await hre.ethers.provider.getBalance(bbContract.address);
  console.log(
    "Contract balance:",
    hre.ethers.utils.formatEther(contractBalance)
  );

  console.log("formulas counter %d", await bbContract.getFormulasCount());

  bbContract.connect(randomPerson);
  bbTxn = await bbContract.addFormula("t>>256");
  await bbTxn.wait();
  bbTxn = await bbContract.addFormula("t/16");
  await bbTxn.wait();
};

const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.log(error);
    process.exit(1);
  }
};

runMain();
