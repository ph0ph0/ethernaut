// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import './Level8.sol';
import './16-Preservation.sol';

contract PreservationFactory is Level {

  address timeZone1LibraryAddress;
  address timeZone2LibraryAddress;

  constructor() {
    timeZone1LibraryAddress = address(new LibraryContract());
    timeZone2LibraryAddress = address(new LibraryContract());
  }

  function createInstance(address _player) override public payable returns (address) {
    _player;
    return address(new Preservation(timeZone1LibraryAddress, timeZone2LibraryAddress));
  }

  function validateInstance(address payable _instance, address _player) override public view returns (bool) {
    Preservation preservation = Preservation(_instance);
    return preservation.owner() == _player;
  }
}