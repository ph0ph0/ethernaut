// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";

interface GatekeeperOne {
    function enter(bytes8 _gateKey) external returns (bool);
}

contract GatekeeperOneAttack {

    address eoa;
    GatekeeperOne gatekeeperOne;
    

    constructor(address _eoa, address _gkoAddress) {
        eoa = _eoa;
        gatekeeperOne = GatekeeperOne(_gkoAddress);

    }

    function attack() public {
        bytes8 _gateKey;
        uint160 eoaUint160 = uint160(eoa);
        console.log("eoaUint160: ", eoaUint160);
        console.log("eoaUint16", uint16(eoaUint160));
        console.log("uint16AddrDirectly", uint16(0x02cf));
        uint64 value = 0x230E85a291190b4;
        bytes8 valueAsBytes = bytes8(value);
        console.logBytes8(valueAsBytes);
        // 0x0230e85a291190b4
        uint64 i = uint64(valueAsBytes);
        console.log("i", i);
        // 18446744073709551616
        // 10534176101865001140
        // 10534176101864935604
        // 10534175002353307828
        // 157881460891685044
        // 157881460891685044

        // gatekeeperOne.enter(_gateKey);
    }
}