pragma solidity ^0.8.0;

// THis doesn't solve the problem, as its bytecode is too long.
// The solution is in the associated test
contract Solver {
    function whatIsTheMeaningOfLife() external pure returns (bytes32) {
        return 0x000000000000000000000000000000000000000000000000000000000000002a;
    }
}
