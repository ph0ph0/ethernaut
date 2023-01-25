// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/console.sol";

contract GatekeeperTwo {

  address public entrant;

  modifier gateOne() {
    require(msg.sender != tx.origin, "Failed g1");
    _;
  }

  modifier gateTwo() {
    uint x;
    assembly { x := extcodesize(caller()) }
    require(x == 0, "Failed g2");
    _;
  }

  modifier gateThree(bytes8 _gateKey) {
    require(uint64(bytes8(keccak256(abi.encodePacked(msg.sender)))) ^ uint64(_gateKey) == type(uint64).max, "Failed g3");
    _;
  }

  function check() public view {
    // uint64(bytes8(keccak256(abi.encodePacked(msg.sender)))) ^ uint64(_gateKey) == type(uint64).max;
    console.log("msg.sender", msg.sender);
    console.log("tx.origin", tx.origin);
    require(msg.sender != tx.origin, "Failed g1");
    uint x;
    assembly { x := extcodesize(caller()) }
    require(x == 0, "Failed g2");
    uint64 _gateKey = ~uint64(bytes8(keccak256(abi.encodePacked(msg.sender))));
    
    require(uint64(bytes8(keccak256(abi.encodePacked(msg.sender)))) ^ uint64(_gateKey) == type(uint64).max, "Failed g3");
  }

  function enter(bytes8 _gateKey) public gateOne gateTwo gateThree(_gateKey) returns (bool) {
    entrant = tx.origin;
    return true;
  }
}