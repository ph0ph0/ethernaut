// SPDX-License-Identifier: UNLICENSED
// forge test -vvvvv --match-path '*18-MagicNumber.t.sol'
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../contracts/18-MagicNumber.sol";
import "../contracts/18-MagicNumberFactory.sol";
import "../lib/forge-std/src/console2.sol";

contract MagicNumberTest is Test {
    MagicNumberFactory public factoryContract;
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
        factoryContract = new MagicNumberFactory();

        // Deploy challenge contract
        challengeAddress = factoryContract.createInstance(address(eoa));
    }

    function afterRun() public view returns (bool) {
        return factoryContract.validateInstance(payable(address(challengeAddress)), eoa);
    }

    function testCheck() public {
        // CREATE2 deploy our bytecode solution
        bytes memory bytecode =
            "\x60\x0a\x60\x0c\x60\x00\x39\x60\x0a\x60\x00\xf3\x60\x2a\x60\x80\x52\x60\x20\x60\x80\xf3";
        bytes32 salt = 0xdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeef;

        address addr;
        assembly {
            addr := create2(0, add(bytecode, 0x20), mload(bytecode), salt)
        }
        require(addr != address(0), "Contract deployment failed");
        console2.log("address:", addr);

        // Set the solver property to our address
        MagicNumber(challengeAddress).setSolver(addr);

        // Retrieve the solver from the instance.
        Solver solver = Solver(MagicNumber(challengeAddress).solver());
        console2.log("running magic");
        // Query the solver for the magic number.
        bytes32 magic = solver.whatIsTheMeaningOfLife();
        console2.log("magic: ");
        console2.logBytes32(magic);
        assertEq(magic, 0x000000000000000000000000000000000000000000000000000000000000002a, "number was not 42");

        assertEq(factoryContract.validateInstance(payable(address(challengeAddress)), eoa), true, "Failed challenge");
    }
}
