// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "hardhat/console.sol";

contract Token {

  mapping(address => uint) balances;
  uint public totalSupply;

  constructor(uint _initialSupply) public {
    balances[msg.sender] = totalSupply = _initialSupply;
  }

  function transfer(address _to, uint _value) public returns (bool) {
    require(balances[msg.sender] - _value >= 0, "balance not sufficient");
    console.log("balance of msg.sender: ", balances[msg.sender]);
    console.log("balance of ", msg.sender, "after transfer after transfer will be: ", balances[msg.sender] - _value);
    console.log("value is: ", _value);
    console.log("balance of msg.sender is: ", balances[msg.sender]);
    balances[msg.sender] -= _value;
    console.log("balance minus value: ", balances[msg.sender]);
    balances[_to] += _value;
    console.log("balance plus value: ", balances[_to] += _value);

    return true;
  }

  function balanceOf(address _owner) public view returns (uint balance) {
    return balances[_owner];
  }
}