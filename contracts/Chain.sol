// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import './Order.sol';

/**
 * @title Chain
 * @dev Manage the creation, acceptance, and rejection of orders
 */
contract Chain {
    mapping(uint256 => Order) private orderInstances;
    uint256 private lastOrderId = 0;

    /**
     * @dev Create a new order
     * @param _restaurant Address of the restaurant
     * @param _deliveryPrice Delivery price for the order
     * @param _total Total cost of the order
     * @param _items List of items in the order
     * @param _itemsClient List of items for the client
     * @return The unique identifier of the created order
     */
    function makeOrder(address _restaurant, uint256 _deliveryPrice, uint256 _total, string memory _items, string memory _itemsClient) public payable returns (uint256) {
        lastOrderId++;
        orderInstances[lastOrderId] = new Order{value: msg.value}(lastOrderId, msg.sender, _restaurant, _deliveryPrice, _total, _items, _itemsClient);
        return lastOrderId;
    }

    /**
     * @dev Find the address of a specific order
     * @param orderId The unique identifier of the order
     * @return The address of the specified order
     */
    function findOrderAddress(uint256 orderId) public view returns (address) {
        return address(orderInstances[orderId]);
    }

    /**
     * @dev Get the index of the last order
     * @return The index of the last order
     */
    function getLastOrderId() public view returns (uint256) {
        return lastOrderId;
    }
}
