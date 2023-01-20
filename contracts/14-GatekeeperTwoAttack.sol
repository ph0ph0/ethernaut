pragma solidity ^0.8.0;
import "hardhat/console.sol";

interface GatekeeperTwo {
    function enter(bytes8 _gateKey) external returns (bool);
    function check() external;
}

contract GatekeeperTwoAttack {

    GatekeeperTwo gateKeeper;

    constructor(address addr) {
        gateKeeper = GatekeeperTwo(addr);
        gateKeeper.check();
    }
}