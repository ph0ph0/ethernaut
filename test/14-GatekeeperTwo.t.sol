// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../contracts/14-GatekeeperTwoAttack.sol";
import "../contracts/14-GatekeeperTwo.sol";
import "../contracts/14-GatekeeperTwoFactory.sol";


contract GatekeeperTwoTest is Test {

    GatekeeperTwoAttack public gatekeeperAttack;
    GatekeeperTwo public gatekeeper; 
    GatekeeperTwoFactory gTF;   
    address eoa;
    address challengeAddress;

    function createUsers(uint userNum) internal returns(address[] memory) {

        address[] memory users = new address[](userNum);
        for (uint i = 0; i < userNum; i++) {
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
        console2.log("eoa", eoa);

        // Deploy factory to create challenge instance
        gTF = new GatekeeperTwoFactory();
        challengeAddress = gTF.createInstance(eoa);  

        
    }

    function afterRun() public view returns(bool) {
        return gTF.validateInstance(payable(address(challengeAddress)), eoa);
    }

    function testCheck() public {
        // Now all txs will be called from the eoa account
        vm.startPrank(eoa);
        console2.log('address(this)', address(this));
        // eoa deploys attack contract to start attack
        gatekeeperAttack = new GatekeeperTwoAttack(address(challengeAddress));

        // assertEq(afterRun(), true);
        assertEq(afterRun(), true);
    }
}
