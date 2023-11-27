// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import './Order.sol';
import './Chain.sol';

struct OrderDetails {
    uint256 id;
    string items;
    uint256 deliveryPrice;
    string step;
    address restaurant;
    uint256 code;
    uint256 timestampCreation;
    uint256 timestampLastStep;
    address deliveryman;
}

/**
 * @title View
 * @dev View and retrieve information about orders
 */
contract View {
    
    /**
     * @dev Get order details based on the order address
     * @param orderAddress The address of the Order contract
     * @return OrderDetails structure containing order details
     */
    function getOrder(address orderAddress) public view returns (OrderDetails memory) {
        return Order(orderAddress).getItems(msg.sender);
    }
    
    /**
     * @dev Get orders related to the caller
     * @param chainAddress The address of the Chain contract
     * @return An array of OrderDetails structures related to the caller
     */
    function relatedTo(address chainAddress) public view returns (OrderDetails[] memory) {
        uint256 lastOrder = Chain(chainAddress).getIndex();
        address orderAddress;
        uint256 j = 0;
        OrderDetails[] memory result = new OrderDetails[](10);
        
        for (uint256 i = 1; i <= lastOrder; i++) {
            orderAddress = Chain(chainAddress).findAddress(i);
            
            if (Order(orderAddress).relatedTo(msg.sender)) {
                OrderDetails memory order = getOrder(orderAddress);
                result[j % 10] = order;
                j++;
            }
        }
        return result;
    }
    
    /**
     * @dev Get the next order to be taken
     * @param chainAddress The address of the Chain contract
     * @return OrderDetails structure representing the next order to be taken
     */
    function toBeTaken(address chainAddress) public view returns (OrderDetails memory) {
        uint256 lastOrder = Chain(chainAddress).getIndex();
        address orderAddress;
        
        for (uint256 i = 1; i <= lastOrder; i++) {
            orderAddress = Chain(chainAddress).findAddress(i);
            
            if (Order(orderAddress).toBeTaken()) {
                return getOrder(orderAddress);
            }
        }
        
        // Return an empty order if no order is available to be taken
        return OrderDetails(0, "", 0, "", address(0), 0, 0, 0, address(0));
    }
}
