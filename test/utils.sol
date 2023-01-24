// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

 contract Utils is Test {
    function createUsers(uint userNum) external returns(address[] memory) {

        address[] memory users = new address[](userNum);
        for (uint i = 0; i < userNum; i++) {
            address user = vm.addr(uint256(keccak256(abi.encodePacked(i))));

            // Fund user with 100 Eth
            vm.deal(user, 100);
            users[i] = user;
        }
        return users;
    }
}