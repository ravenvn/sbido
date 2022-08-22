const { ethers, upgrades } = require("hardhat");

async function main() {
  const SB = await ethers.getContractFactory("SB");
  /// Deploy
  const sb = await SB.deploy();
  await sb.deployed();

  console.log("Success when deploy SB contract: %s", sb.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
