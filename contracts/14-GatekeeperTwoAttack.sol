pragma solidity ^0.8.0;

interface GatekeeperTwo {
    function enter(bytes8 _gateKey) external returns (bool);
}