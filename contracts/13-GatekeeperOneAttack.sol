// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";

interface GatekeeperOne {
    function enter(bytes8 _gateKey) external returns (bool);
    function checkGateThree(bytes8 _gateKey) external view; 
}

contract GatekeeperOneAttack {

    address eoa;
    GatekeeperOne gatekeeperOne;
    

    constructor(address _eoa, address _gkoAddress) {
        eoa = _eoa;
        gatekeeperOne = GatekeeperOne(_gkoAddress);

    }

    function attack() public {
        // Passing in 719 as the gateKeyInt value passes 3b
        uint64 gateKeyInt = uint64(uint160(719));
        bytes8 _gateKey = bytes8(gateKeyInt);
        // uint16 gateKey = uint16(uint160(eoa));
        console.log("bytes8 _gateKey: ");
        console.logBytes8(_gateKey);
        // ---------------------------
        uint160 eoa_160 = uint160(eoa);
        console.log("eoa_160", eoa_160);
        uint64 eoa_64 = uint64(eoa_160);
        console.log("eoa_64", eoa_64);
        uint32 eoa_32 = uint32(eoa_64);
        console.log("eoa_32", eoa_32);
        uint16 eoa_16 = uint16(eoa_32);
        console.log("eoa_16", eoa_16);
        uint16 eoa_16_160 = uint16(eoa_160);
        console.log("eoa_16_160", eoa_16_160);
        // gatekeeperOne.checkGateThree(_gateKey);
    }
}