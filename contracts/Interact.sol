// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import './Order.sol';
import './Storage.sol';

contract Interact {
    function prepareOrder(address orderAddress) public payable returns (bool) {
        // Renamed the function and variable to be more descriptive
        return Order(orderAddress).acceptOrderAndPay{value: msg.value}(msg.sender);
    }
    
    function confirmIntention(address orderAddress, uint256 index, address storageAddress, bytes32 firstHalf, bytes32 secondHalf) public payable {
        // Updated function name and variable
        Order(orderAddress).confirmIntentionAndPay{value: msg.value}(msg.sender);
        Storage(storageAddress).addDeliveryman(index, firstHalf, secondHalf);
    }
    
    function callSecondDeliveryman(address orderAddress) public returns (bool) {
        // Renamed the function for clarity
        return Order(orderAddress).callSecondDeliveryman(msg.sender);
    }
    
    function pickupOrder(address orderAddress, uint256 code) public returns (bool) {
        return Order(orderAddress).pickupOrderAndCheckCode(msg.sender, code);
    }
    
    function deliveryOrder(address orderAddress, uint256 code) public {
        Order(orderAddress).deliveryOrderAndCheckCode(msg.sender, code);
    }
    
    function contestOrder(address orderAddress, bool available) public {
        // Updated the function name for clarity
        Order(orderAddress).contestOrderAndProvideFeedback(msg.sender, available);
    }

    function cancelOrder(address orderAddress) public {
        Order(orderAddress).cancelOrderByCaller(msg.sender);
    }
    
    function withdraw(address orderAddress) public payable {
        Order(orderAddress).withdrawByCaller(msg.sender);
    }
}
