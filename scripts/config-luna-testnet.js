const { ethers, upgrades } = require("hardhat");

const PriSale_ADDRESS = "0x4F4017F5Fbd245dBE6a6315D3BC12c3357a1Fcf9";

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