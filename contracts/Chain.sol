pragma solidity >=0.4.22 <0.9.0;

contract Migrations {
  address public contractOwner = msg.sender;
  uint public lastCompletedMigration;

  modifier onlyOwner() {
    require(
      msg.sender == contractOwner,
      "This function is restricted to the contract's owner"
    );
    _;
  }
}
