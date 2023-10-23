import "../lib/forge-std/src/console2.sol";

contract MotorbikeAttack {
    
    function destroy() public {
        console2.log("Destroying contract", address(this));
        selfdestruct(msg.sender);
        console2.log("Destroyed contract", address(this));
    }
}