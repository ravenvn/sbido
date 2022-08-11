// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract RefSalePrivateSale is OwnableUpgradeable {
    using SafeMath for uint256;

    IERC20 public token;

    // Mainnet
    // IERC20  BUSD = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    // Testnet 
    // IERC20 BUSD = IERC20(0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee);
    IERC20 public BUSD ;

    bool public enabled;

    uint256 public privateSalePrice;

    uint256 public maxRaisedBUSD;

    bool public claimEnabled;

    uint256 public minBUSDBoughtPerWallet;

    uint256 public maxBUSDBoughtPerWallet;

    struct UserData{
        uint256 totalBUSDAmountContributed;
        uint256 tokenAmountReceived;
        uint256 totalRewardAmount;
        uint256 rewardAmountReceived;
    }

    mapping(address => UserData) public addressToUserData;

    address[] public users;

    uint256 public referralBonusPercent;

    uint256 public totalRewardTracking; // all BUSD amount for referralAddress
    //unlock token percent 
    uint256 public releaseTokenTotalPercent; // 1% = 1000

    uint256 public instantRelease; // date of instantRelease  1972 datetime

    uint256 public maxHoldingTime;  // seconds , one year = 60*60*24*365 = 31536000

    uint256 public startReleaseTime; // seconds

    event Received(address, uint256);
    
    event Bought(address buyer, uint256 tokenAmount);

    function initialize(IERC20 _token) public initializer {
        token = _token;
        enabled = false;
        privateSalePrice = 0.0002 ether;
        claimEnabled = false;
        maxRaisedBUSD = 100000 ether;
        minBUSDBoughtPerWallet = 100 ether;
        maxBUSDBoughtPerWallet = 10000 ether;
        referralBonusPercent = 20000; //mini percent  10% = 10000 , 100% = 100 000
        maxHoldingTime = 31536000;
        startReleaseTime = block.timestamp;
        instantRelease = block.timestamp + maxHoldingTime;
        releaseTokenTotalPercent = 0;
        BUSD = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
        __Ownable_init();
    }
    
    function setStartReleaseTime(uint256 date) external onlyOwner {
        startReleaseTime = date;
    }
    // if set _referralBonusPercent = 1000 it means 1% ; 
    function setReferralBonusPercent(uint256 _referralBonusPercent) external onlyOwner {
        referralBonusPercent = _referralBonusPercent;
    }

    function setMinBUSDBoughtPerWallet(uint256 _minBUSD) external onlyOwner{
        minBUSDBoughtPerWallet = _minBUSD;
    }

    function setMaxBUSDBoughtPerWallet(uint256 _maxBUSD) external onlyOwner {
        maxBUSDBoughtPerWallet = _maxBUSD;
    }

    function setToken(IERC20 _token) external onlyOwner {
        token = _token;
    }

    function setBUSDAddress(IERC20 _busd)  external onlyOwner{
        BUSD = _busd;
    }

    function setClaimEnabled(bool _claimEnabled) external onlyOwner {
        claimEnabled = _claimEnabled;
    }

    function setEnabled(bool _enabled) external onlyOwner {
        enabled = _enabled;
    }
    //wei value
    function setPrivateSalePrice(uint256 _privateSalePrice) external onlyOwner {
        privateSalePrice = _privateSalePrice;
    }

    function setMaxRaisedBUSD(uint256 _maxRaisedBUSD) external onlyOwner {
        maxRaisedBUSD = _maxRaisedBUSD;
    }
    //one year = 60*60*24*365 = 31536000 seconds
    function setMaxHoldingTime(uint256 _holdingTime) external onlyOwner{
        maxHoldingTime = _holdingTime;
    }
    //1000 it means 1% ;
    function setInstantReleaseWithPercent(uint256 _miniPercent) external onlyOwner{
        instantRelease = block.timestamp;
        require(releaseTokenTotalPercent.add(_miniPercent) <= 100000,"Total percent than more 100%");
        releaseTokenTotalPercent = releaseTokenTotalPercent.add(_miniPercent);
    }
    // busdAmount is wei value
    function buyToken(uint256 busdAmount, address referAddress) external  {
        require(enabled, "PrivateSale is disabled");

        require(block.timestamp >= startReleaseTime,"PrivateSale does not open sale");
        
        require(busdAmount >= minBUSDBoughtPerWallet, "You can not buy less than the Min threshold");

        require(busdAmount <= maxBUSDBoughtPerWallet, "You can not buy more than the Max threshold");

        require(BUSD.balanceOf(address(this)).add(busdAmount) <= maxRaisedBUSD, "Max raised BUSD amount exceeded");
        //user transfer BUSD to contract
        require(BUSD.transferFrom(msg.sender,address(this),busdAmount),"Failure On BUSD Transfer");
        

        addressToUserData[msg.sender].totalBUSDAmountContributed = addressToUserData[
            msg.sender
        ].totalBUSDAmountContributed.add(busdAmount);

        // check referral 
        if(referAddress != address(0)){
            uint256 reward = (busdAmount.mul(referralBonusPercent)).div(100000);
            addressToUserData[referAddress].totalRewardAmount =  addressToUserData[referAddress].totalRewardAmount.add(reward);
            totalRewardTracking = totalRewardTracking.add(reward);
        }

        emit Bought(msg.sender, busdAmount);
    }

    function claimToken() external  {

        require(claimEnabled, "PrivateSale is not claimable");

        uint256 currentTime = block.timestamp;

        require((currentTime >= instantRelease || currentTime >= (maxHoldingTime + startReleaseTime)&&(currentTime >= startReleaseTime)),"Release not yet due");

        require(address(token) != address(0),"Token do not update");

        uint256 eth = 1 ether;
        
        uint256 totalTokenRelease = addressToUserData[msg.sender].totalBUSDAmountContributed.mul(releaseTokenTotalPercent).mul(eth).div(privateSalePrice).div(100000);

        if(currentTime >= (maxHoldingTime + startReleaseTime)){
            totalTokenRelease = addressToUserData[msg.sender].totalBUSDAmountContributed.mul(eth).div(privateSalePrice);
        }

        require(addressToUserData[msg.sender].tokenAmountReceived <= totalTokenRelease,"Can not claim more");

        uint256 tokenAmountCanReceive = totalTokenRelease.sub(addressToUserData[msg.sender].tokenAmountReceived);

        addressToUserData[msg.sender].tokenAmountReceived = totalTokenRelease;

        token.transfer(
            msg.sender,
            tokenAmountCanReceive
        );
        
        emit Received(msg.sender, tokenAmountCanReceive);
    }

    function claimReward() external {
        uint256 reward = addressToUserData[msg.sender].totalRewardAmount - addressToUserData[msg.sender].rewardAmountReceived;

        addressToUserData[msg.sender].rewardAmountReceived = addressToUserData[msg.sender].totalRewardAmount;

        require(reward >  0, "No reward");
        
        uint256 referBusdAmount = addressToUserData[msg.sender].totalBUSDAmountContributed;

        require(referBusdAmount > 0,"You need to buy private sale to be able to get reward");

        require(BUSD.transfer(msg.sender,reward),"Transfer busd to refer fail");

        totalRewardTracking = totalRewardTracking.sub(reward);
       
    }

    function canClaimToken() external view returns(bool){

        uint256 eth = 1 ether;
        
        uint256 totalTokenRelease = (addressToUserData[msg.sender].totalBUSDAmountContributed.mul(eth).mul(releaseTokenTotalPercent)).div(100000).div(privateSalePrice);
       
        uint256 received = addressToUserData[msg.sender].tokenAmountReceived;

        if(received == totalTokenRelease){
            return false;
        }else {
            return true;
        }
    }

    function canClaimReward() external view returns(bool){

        require(addressToUserData[msg.sender].totalRewardAmount >= addressToUserData[msg.sender].rewardAmountReceived,"Can not claim more");

        uint256 reward = addressToUserData[msg.sender].totalRewardAmount - addressToUserData[msg.sender].rewardAmountReceived;

        if(reward > 0){
            return true;
        }else{
            return false;
        }
    }

    function transferToken(address _recipient, uint256 _amount)
        external
        onlyOwner
        returns (bool)
    {
        return token.transfer(_recipient, _amount);
    }

    function transferBUSD(address _recipient, uint256 _amount)
        external
        onlyOwner returns(bool)
    {
        return BUSD.transfer(_recipient,_amount);
    }

    function getTokenBalanceOfContract() external view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function getBUSDBalanceOfContract() external view returns (uint256) {
        return BUSD.balanceOf(address(this));
    }
}
