// SPDX-License-Identifier: UNLICENSED
// forge test -vvvvv --match-path '*21-Shop.t.sol'
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../contracts/21-Shop.sol";
import "../contracts/21-ShopFactory.sol";
import "../contracts/21-ShopAttack.sol";
import "../lib/forge-std/src/console2.sol";
import {ShopAttack} from "../contracts/21-ShopAttack.sol";

contract ShopTest is Test {
    ShopFactory public factoryContract;
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
        factoryContract = new ShopFactory();

        // Deploy challenge contract
        challengeAddress = factoryContract.createInstance{value: 1 ether}(address(eoa));
    }

    // function afterRun() public returns (bool) {
    //     return factoryContract.validateInstance(payable(address(challengeAddress)), eoa);
    // }

    function testCheck() public {
        // Get Challenge Instance
        Shop challenge = Shop(address(challengeAddress));

        // Deploy ShopAttack contract
        ShopAttack attackContract = new ShopAttack(address(challenge));

        // Call attack on ShopAttack contract
        attackContract.attack();

        // Check if challenge is solved
        bool result = factoryContract.validateInstance(payable(address(challengeAddress)), eoa);
        assertEq(result, true, "Challenge should be solved");

    }
}
