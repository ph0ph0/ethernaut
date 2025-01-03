// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Level8.sol";
import "./27-GoodSamaritan.sol";

contract GoodSamaritanFactory is Level {
    function createInstance(address _player) public payable override returns (address) {
        _player;
        return address(new GoodSamaritan());
    }

    function validateInstance(address payable _instance, address _player) public view override returns (bool) {
        _player;
        GoodSamaritan instance = GoodSamaritan(_instance);
        return instance.coin().balances(address(instance.wallet())) == 0;
    }
}
