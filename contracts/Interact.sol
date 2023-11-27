pragma solidity >=0.7.0 <0.9.0;

import './Order.sol';
import './Storage.sol';

contract Interact {
    function initiateOrder(address orderContractAddress) public payable returns (bool) {
        return Order(orderContractAddress).acceptOrder{value: msg.value}(msg.sender);
    }

    function confirmOrderAndStore(address orderContractAddress, uint256 orderIndex, address storageContractAddress, bytes32 firstHalfKey, bytes32 secondHalfKey) public payable {
        Order(orderContractAddress).confirmOrder{value: msg.value}(msg.sender);
        Storage(storageContractAddress).addDeliveryman(orderIndex, firstHalfKey, secondHalfKey);
    }

    function notifySecondDeliveryman(address orderContractAddress) public returns (bool) {
        return Order(orderContractAddress).notifySecondDeliveryman(msg.sender);
    }
}
