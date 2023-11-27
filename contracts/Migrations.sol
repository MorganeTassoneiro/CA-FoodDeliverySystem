// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Migrations {
    address private contractOwner = msg.sender;
    uint256 public lastCompletedMigration;

    modifier onlyOwner() {
        require(msg.sender == contractOwner, "This function is restricted to the contract's owner");
        _;
    }

    /**
     * @dev Set the completed migration
     * @param completed The value to set as the last completed migration
     */
    function setCompleted(uint256 completed) public onlyOwner {
        lastCompletedMigration = completed;
    }
}
