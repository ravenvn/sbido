const { ethers, upgrades } = require("hardhat");

const PriSale_ADDRESS = "0xB595169998051843b48567390C3fd44af6323b39";

async function main() {
  const priSale = await ethers.getContractAt("PrivateSale", PriSale_ADDRESS);
  // await priSale.transferToken(
  //   "0x9723429e01A8133005Bf9e7a7426e50a57e35af8",
  //   "99000000000000000000000000"
  // );

  // await priSale.transferOwnership("0x27DF7e6A705270e088447eb09A273cdC81cB39b6");
  const owner = await priSale.owner();
  console.log("new owner:", owner);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
