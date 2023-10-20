// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../contracts/17-Recovery.sol";
import "../contracts/17-RecoveryFactory.sol";
import "../lib/forge-std/src/console2.sol";

contract RecoveryTest is Test {
    RecoveryFactory public factoryContract;
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
        factoryContract = new RecoveryFactory();

        // Deploy challenge contract. 0.001 ether must be sent as well
        challengeAddress = factoryContract.createInstance{value: 0.001 ether}(address(eoa));
    }

    function afterRun() public view returns (bool) {
        return factoryContract.validateInstance(payable(address(challengeAddress)), eoa);
    }

    function testCheck() public {
        // NOTE: The address of the Recovery contract (SimpleToken Factory contract) in the Recovery file is the challenge address. Change the name so it is more clear and print so we can call cast on it.
        address simpleTokenFactoryAddress = challengeAddress;

        // 0x104fBc016F4bb334D775a19E8A6510109AC63E00
        console2.log("SimpleTokenFactoryAddress", simpleTokenFactoryAddress);

        // This is how you calculate a CREATE opcode address using sol.
        address lostAddressTarget = address(
            uint160(
                uint256(
                    keccak256(abi.encodePacked(bytes1(0xd6), bytes1(0x94), simpleTokenFactoryAddress, bytes1(0x01)))
                )
            )
        );

        // log lostAddressTarget
        console2.log("lostAddressTarget", lostAddressTarget);
        // log lostAddress in the list
        console2.log("lostAddress in the list", factoryContract.lostAddressList(0));

        // Create an instance of the SimpleTokenContract using the simpleTokenFactoryAddress
        address payable lostAddressTargetAddressPayable = payable(lostAddressTarget);
        SimpleToken simpleTokenContract = SimpleToken(lostAddressTargetAddressPayable);

        // get the balance of RecoveryFactory
        uint256 balanceOfRecoveryFactory = simpleTokenContract.balances(address(factoryContract));
        // log balanceOfRecoveryFactory
        console2.log("balanceOfRecoveryFactory", balanceOfRecoveryFactory);

        vm.startPrank(address(factoryContract), address(factoryContract));

        // log the lostTargetAddressPayable balance before transfer
        console2.log("lostTargetAddressPayable balance before transfer", lostAddressTargetAddressPayable.balance);
        // Now selfdestruct the contract and send all the ether to the eoa
        simpleTokenContract.destroy(payable(address(eoa)));
        // log the lostTargetAddressPayable balance after transfer
        console2.log("lostTargetAddressPayable balance after transfer", lostAddressTargetAddressPayable.balance);

        // For some stupid reason the validateInstance function takes a second unnamed, and unused argument, so we have to pass in a dummy address that isn't used.
        assertEq(factoryContract.validateInstance(payable(address(challengeAddress)), eoa), true, "Failed challenge");
    }
}
