const { ethers, upgrades } = require("hardhat");

async function main() {
  const PrivateSale = await ethers.getContractFactory("PrivateSale");
  /// Deploy
  const proxy = await upgrades.deployProxy(PrivateSale, [
    ethres.constants.AddressZero,
  ]);
  const proxyResult = await proxy.deployed();

  console.log(
    "Success when deploy PrivateSale contract: %s",
    proxyResult.address
  );
  // Upgrade
  //   const PRESALE_ADDRESS = "0x4367f170B3853C32af33D02d16551328Ec1693B0";
  //   const newProxy = await upgrades.upgradeProxy(PRESALE_ADDRESS, Presale);
  //   console.log("Presale upgraded");

  // npx hardhat verify --network mainnet 0x65a39e9cfd2dD335eC1137E0B2CaF81dF4fD6F27
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
