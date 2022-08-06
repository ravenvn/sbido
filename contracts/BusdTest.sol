// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract BusdTest is ERC20 {
  constructor() ERC20("Busd Test", "BUSD") {
    _mint(msg.sender, 1e9*1e18);
  }
}