pragma solidity >=0.7.0 <0.9.0;

import './Order.sol';

/**
 * @title Chain
 * @dev Make, accept, reject orders
 */
contract Chain {
    mapping(uint256 => Order) private orderMapping;
    uint256 private latestOrderIndex = 0;

    function createOrder(address _restaurant, uint256 _deliveryPrice, uint256 _total, string memory _items, string memory _clientItems) public payable returns (uint256) {
        latestOrderIndex++;
        orderMapping[latestOrderIndex] = new Order{value: msg.value}(latestOrderIndex, msg.sender, _restaurant, _deliveryPrice, _total, _items, _clientItems);
        return latestOrderIndex;
    }
}   
 function getAddressByOrder(uint256 orderIndex) public view returns (address) {
        return address(orderMapping[orderIndex]);
    }
    
    function getLatestOrderIndex() public view returns (uint256) {
        return latestOrderIndex;
    }



