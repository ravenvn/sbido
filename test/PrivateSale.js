const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("PrivateSale", () => {
  let busdTest;
  let testToken;
  let privateSale;
  before(async () => {
    [owner, user1, user2, user3, user4, user5, ...addrs] =
      await ethers.getSigners();
    const TestToken = await ethers.getContractFactory("TestToken");
    const BusdTest = await ethers.getContractFactory("BusdTest");
    const PrivateSale = await ethers.getContractFactory("PrivateSale");
    testToken = await TestToken.deploy();
    privateSale = await PrivateSale.deploy();
    busdTest = await BusdTest.deploy();
    await privateSale.initialize(ethers.constants.AddressZero);
    await testToken.deployed();
    await privateSale.deployed();
    await busdTest.deployed();

    const add = await privateSale.owner();
    console.log("privateSale address:", privateSale.address);
    console.log("privateSale Owner:", add);
    console.log("owner acc:", owner.address);
  });

  it("Should buy token well", async function () {
    await busdTest.transfer(user1.address, ethers.utils.parseEther("1000"));
    const busd_user1 = await busdTest.balanceOf(user1.address);
    await expect(ethers.utils.formatEther(busd_user1)).to.equal("1000.0");
    await busdTest.transfer(user2.address, ethers.utils.parseEther("250"));

    //set enable buy
    await privateSale.setEnabled(true);
    await privateSale.setBUSDAddress(busdTest.address);

    const priceBusd = 1000000 * ethers.utils.parseEther("0.0004");
    await busdTest
      .connect(user1)
      .approve(
        privateSale.address,
        ethers.utils.parseEther(priceBusd.toString())
      );
    await privateSale.connect(user1).buyToken("1000000", user2.address);

    const busd_privateSale = await busdTest.balanceOf(privateSale.address);
    expect(busd_privateSale).to.equal(priceBusd.toString());
  });

  it("Should claim reward well", async function () {
    //user1 buy 400 ether = > user2 got reward 40 ether
    await expect(privateSale.connect(user2).claimReward()).to.be.revertedWith(
      "You need to buy private sale to be able to get reward"
    );

    //want to get reward user2 need to buy token
    const priceBusd = 500000 * ethers.utils.parseEther("0.0004");
    await busdTest
      .connect(user2)
      .approve(
        privateSale.address,
        ethers.utils.parseEther(priceBusd.toString())
      );
    await privateSale.connect(user2).buyToken("500000", user1.address);

    await privateSale.connect(user2).claimReward();

    const user2_reward = await busdTest.balanceOf(user2.address);
    expect(ethers.utils.formatEther(user2_reward)).to.equal("90.0");
  });

  it("Should claim token well", async function () {
    await expect(privateSale.connect(user1).claimToken()).to.be.revertedWith(
      "PrivateSale is not claimable"
    );

    await privateSale.setClaimEnabled(true);
    await expect(privateSale.connect(user1).claimToken()).to.be.revertedWith(
      "Release not yet due"
    );

    await privateSale.setInstantReleaseWithPercent("10000"); // set 10%

    await expect(privateSale.connect(user1).claimToken()).to.be.revertedWith(
      "Token do not update"
    );

    await privateSale.setToken(testToken.address);

    await expect(privateSale.connect(user1).claimToken()).to.be.revertedWith(
      "ERC20: transfer amount exceeds balance"
    );

    await testToken.transfer(
      privateSale.address,
      ethers.utils.parseEther("10000000")
    );

    await privateSale.connect(user1).claimToken();

    await privateSale.setInstantReleaseWithPercent("50000"); // set 50%

    await privateSale.connect(user1).claimToken();

    await expect(
      privateSale.setInstantReleaseWithPercent("50000")
    ).to.be.revertedWith("Total percent than more 100%");
    privateSale.setInstantReleaseWithPercent("40000");
    await privateSale.connect(user1).claimToken();
    const user1_token = await testToken.balanceOf(user1.address);
    console.log("user1_token", user1_token);

    const user2Data = await privateSale.addressToUserData(user2.address);
    console.log("user2 data", user2Data);
  });
});
