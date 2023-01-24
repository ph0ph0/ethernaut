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
        gateKeeperTwo.check();
    }
}