// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import './Level8.sol';
import './14-GatekeeperTwo.sol';

// import "hardhat/console.sol";

contract GatekeeperTwoFactory is Level {

  function createInstance(address _player) override public payable returns (address) {
    _player;
    GatekeeperTwo instance = new GatekeeperTwo();
    address deployer = instance.entrant();
    console.log("intial entrant: ");
    console.logAddress(deployer);
    return address(instance);
  }

  function validateInstance(address payable _instance, address _player) override public view returns (bool) {
    GatekeeperTwo instance = GatekeeperTwo(_instance);
    console.log('validate entrant:');
    console.logAddress(instance.entrant());
    console.log(' validate player:');
    console.logAddress(_player);
    return instance.entrant() == _player;
  }
}