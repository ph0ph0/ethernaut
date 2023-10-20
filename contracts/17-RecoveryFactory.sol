// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Level8.sol";
import "./17-Recovery.sol";
import "forge-std/Test.sol";

contract RecoveryFactory is Level {
    mapping(address => address) lostAddress;
    // I added a mapping to keep track of the lost address
    address[1] public lostAddressList;

    function createInstance(address _player) public payable override returns (address) {
        require(msg.value >= 0.001 ether, "Must send at least 0.001 ETH");

        Recovery recoveryInstance;
        recoveryInstance = new Recovery();
        // create a simple token
        recoveryInstance.generateToken("InitialToken", uint256(100000));
        // the lost address
        address lostAddressVal = address(
            uint160(uint256(keccak256(abi.encodePacked(uint8(0xd6), uint8(0x94), recoveryInstance, uint8(0x01)))))
        );
        // add the lost address to the mapping
        lostAddress[address(recoveryInstance)] = lostAddressVal;
        // add the lost address to the list
        lostAddressList[0] = lostAddressVal;

        // Send it some ether
        (bool result,) = lostAddress[address(recoveryInstance)].call{value: msg.value}("");
        require(result);

        return address(recoveryInstance);
    }

    function validateInstance(address payable _instance, address) public view override returns (bool) {
        return address(lostAddress[_instance]).balance == 0;
    }
}
