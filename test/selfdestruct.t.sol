// This test was created to investigate what happens to the ether sent to a contract that selfdestructs.
// The conclusion is that the value transfer call within the selfdestruct call is executed immediately.
// This is why the eoa receives the ether before the selfdestruct call is executed, where the contract is destroyed at the end of the call.
// You would expect the ether to be sent to the recipient contract, but it is not.

import {Test, console2} from "forge-std/Test.sol";
import "../contracts/selfdestruct.sol";

contract SelfDestructTest is Test {
    SelfDestruct public selfDestruct;
    Recipient public recipient;
    address public eoa;
    address payable recipientAddress;

    function createUsers(uint256 userNum) internal returns (address[] memory) {
        address[] memory users = new address[](userNum);
        for (uint256 i = 0; i < userNum; i++) {
            // Compute the address from the given priv key
            address user = vm.addr(uint256(keccak256(abi.encodePacked(i))));

            vm.deal(user, 2 ether);

            users[i] = user;
        }
        return users;
    }

    function test_SelfDestruct() public {
        // Create EOA and take the 0th (1st) element from the returned array
        eoa = createUsers(1)[0];
        console2.log("eoaBalanceBefore", eoa.balance / 1e18);

        recipient = new Recipient();
        recipientAddress = payable(address(recipient));

        vm.startPrank(eoa, eoa);
        selfDestruct = new SelfDestruct{value: 1 ether}(recipientAddress);

        address payable selfDestructAddress = payable(address(selfDestruct));

        (bool success, bytes memory returndata) = (selfDestructAddress.call{value: 1 ether}(""));

        // if the function call reverted
        if (success == false) {
            // if there is a return reason string
            if (returndata.length > 0) {
                // bubble up any reason for revert
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert("Function call reverted");
            }
        }

        // Balance before self destruct of selfDestruct contract
        console2.log("selfDestructBalanceBefore", address(selfDestruct).balance / 1e18);

        // kill selfDestruct contract
        selfDestruct.kill();

        // Recipient should receive all ether, but it doesn't...
        console2.log("RecipientBalanceAfter", recipientAddress.balance / 1e18);

        // eoa should have none, but it does receive all ether...
        console2.log("eoaBalanceAfter", eoa.balance / 1e18);

        bytes memory bytecode = vm.getDeployedCode("selfdestruct.sol:SelfDestruct");

        console2.logBytes(bytecode);
    }
}
