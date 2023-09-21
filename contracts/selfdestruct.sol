// This is a contract to test selfdestruct

contract SelfDestruct {
    Recipient recipient;

    constructor(address payable recipientAddress) payable {
        recipient = Recipient(recipientAddress);
    }

    function kill() public {
        selfdestruct(payable(msg.sender));

        address payable recipientAddress = payable(address(recipient));
        recipientAddress.call{value: 1 ether}("");
    }

    receive() external payable {}
}

contract Recipient {
    receive() external payable {}
}
