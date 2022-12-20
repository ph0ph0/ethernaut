// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import './Level8.sol';
import './13-GatekeeperOne.sol';

contract GatekeeperOneFactory is Level {

  function createInstance(address _player) override public payable returns (address) {
    _player;
    GatekeeperOne instance = new GatekeeperOne();
    return address(instance);
  }

  function validateInstance(address payable _instance, address _player) override public view returns (bool) {
    GatekeeperOne instance = GatekeeperOne(_instance);
    return instance.entrant() == _player;
  }
}