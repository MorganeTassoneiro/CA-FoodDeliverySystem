// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

library Util {
    struct Item {
        string name;
        uint quantity;
        uint256 price;
    }
    
    function getOrderStepValue(Order.OrderStep _step) external pure returns (string memory) {
        // Loop through possible options
        if (Order.OrderStep.ORDERED == _step) return "ORDERED";
        else if (Order.OrderStep.PREPARATION == _step) return "PREPARATION";
        else if (Order.OrderStep.WAITING == _step) return "WAITING";
        else if (Order.OrderStep.DISPATCHED == _step) return "DISPATCHED";
        else if (Order.OrderStep.CONCLUDED == _step) return "CONCLUDED";
        else if (Order.OrderStep.CANCELEDBYCLIENT == _step) return "CANCELED BY CLIENT";
        else if (Order.OrderStep.CANCELEDBYRESTAURANT == _step) return "CANCELED BY RESTAURANT";
        else if (Order.OrderStep.CANCELEDBYFIRSTDELIVERYMAN == _step) return "CANCELED BY FIRST DELIVERYMAN";
        else if (Order.OrderStep.CANCELEDBYSECONDDELIVERYMAN == _step) return "CANCELED BY SECOND DELIVERYMAN";
        else return "UNKNOWN";
    }
    
    function onlyByMembers(address _caller, address client, address restaurant, address[] memory deliverymen) external pure returns (bool) {
        if (deliverymen.length == 0 && _caller != client && _caller != restaurant)
            return false;
        else if (deliverymen.length == 1 && _caller != client && _caller != restaurant && _caller != deliverymen[0])
            return false;
        else if (deliverymen.length == 2 && _caller != client && _caller != restaurant && _caller != deliverymen[1])
            return false;
        else
            return true;
    }
    
    function random(uint256 timestamp, uint256 difficulty) external pure returns (uint256) {
        return uint8(uint256(keccak256(abi.encodePacked(timestamp, difficulty))) % 10000);
    }
    
    function whoCancel(
        address _caller,
        Order.OrderStep _step,
        address client,
        address restaurant,
        address[] memory deliverymen,
        uint256 now_time,
        uint256 timestamp
    ) external pure returns (Order.OrderStep) {
        if (Order.OrderStep.ORDERED == _step && _caller == client) return Order.OrderStep.CANCELEDBYRESTAURANT;
        else if (Order.OrderStep.ORDERED == _step && _caller == restaurant) return Order.OrderStep.CANCELEDBYRESTAURANT;
        else if (Order.OrderStep.PREPARATION == _step && now_time > timestamp + 3600) return Order.OrderStep.CANCELEDBYRESTAURANT;
        else if (Order.OrderStep.PREPARATION == _step && _caller == client) return Order.OrderStep.CANCELEDBYCLIENT;
        else if (Order.OrderStep.PREPARATION == _step && _caller == restaurant) return Order.OrderStep.CANCELEDBYRESTAURANT;
        else if (Order.OrderStep.WAITING == _step && now_time > timestamp + 3600) return Order.OrderStep.CANCELEDBYRESTAURANT;
        else if (Order.OrderStep.WAITING == _step && _caller == client) return Order.OrderStep.CANCELEDBYCLIENT;
        else if (Order.OrderStep.WAITING == _step && _caller == restaurant) return Order.OrderStep.CANCELEDBYRESTAURANT;
        else if (deliverymen.length == 1 && Order.OrderStep.DISPATCHED == _step && now_time > timestamp + 3600) return Order.OrderStep.CANCELEDBYFIRSTDELIVERYMAN;
        else if (deliverymen.length == 2 && Order.OrderStep.DISPATCHED == _step && now_time > timestamp + 3600) return Order.OrderStep.CANCELEDBYSECONDDELIVERYMAN;
        else if (Order.OrderStep.DISPATCHED == _step && _caller == client) return Order.OrderStep.CANCELEDBYCLIENT;
        else if (Order.OrderStep.DISPATCHED == _step && _caller == restaurant) return Order.OrderStep.CANCELEDBYRESTAURANT;
        else if (deliverymen.length == 1 && Order.OrderStep.DISPATCHED == _step && _caller == deliverymen[0]) return Order.OrderStep.CANCELEDBYFIRSTDELIVERYMAN;
        else if (deliverymen.length == 2 && Order.OrderStep.DISPATCHED == _step && _caller == deliverymen[1]) return Order.OrderStep.CANCELEDBYSECONDDELIVERYMAN;
        else return _step;
    }
    
    function payment(
        Order.OrderStep step,
        address order,
        uint256 total,
        uint256 deliveryPrice,
        uint256 deliverymen
    ) external view returns (uint256, uint256, uint256, uint256) {
        uint256 client;
        uint256 restaurant;
        uint256 deliveryman_1;
        uint256 deliveryman_2;
        (client, restaurant, deliveryman_1, deliveryman_2) = Order(order).getPayment();
        if (step == Order.OrderStep.CONCLUDED || step == Order.OrderStep.CANCELEDBYCLIENT) {
            if (deliverymen == 1) return (client - total - deliveryPrice, restaurant + total, deliveryman_1 + deliveryPrice, 0);
            else if (deliverymen == 2) return (client - total - deliveryPrice, restaurant + total, deliveryman_1, deliveryman_2 + deliveryPrice);
            else return (client - total, restaurant + total, 0, 0);
        } else if (step == Order.OrderStep.CANCELEDBYRESTAURANT) {
            if (deliverymen == 1) return (client, restaurant - deliveryPrice, deliveryman_1 + deliveryPrice, 0);
            else if (deliverymen == 2) return (client, restaurant - deliveryPrice, deliveryman_1, deliveryman_2 + deliveryPrice);
            else return (client, restaurant, 0, 0);
        } else if (step == Order.OrderStep.CANCELEDBYFIRSTDELIVERYMAN) {
            if (deliverymen == 1) return (client, restaurant + total, deliveryman_1 - total, 0);
            else return (client, restaurant + total, deliveryman_1 - total, deliveryman_2);
        } else if (step == Order.OrderStep.CANCELEDBYSECONDDELIVERYMAN) {
            return (client, restaurant + total, deliveryman_1, deliveryman_2 - total);
        } else return (0, 0, 0, 0);
    }
}

contract Order {
    enum OrderStep {ORDERED, PREPARATION, WAITING, DISPATCHED, CONCLUDED, CANCELEDBYCLIENT, CANCELEDBYRESTAURANT, CANCELEDBYFIRSTDELIVERYMAN, CANCELEDBYSECONDDELIVERYMAN}

    uint256 private id;
    address private client;
    address private restaurant;
    address[] private deliverymen;
    uint256 private deliveryPrice;
    uint256 private total;
    OrderStep private step;
    mapping(OrderStep => uint256) private timestamp;
    mapping(address => uint256) private payment;
    string private items;
    string private itemsClient;
    
    uint256 private clientCode;
    uint256[2] private deliverymenCode;
    
    /// @dev Function cannot be called at this time.
    string private constant FunctionInvalidAtThisStep = "Function cannot be called at this step";
    
    /// @dev Sender not authorized for this operation.
    string private constant Unauthorized = "This caller is unauthorized";
    
    modifier clientRestricted {
        require(client == msg.sender, Unauthorized);
        _;
    }
    
    modifier onlyBy(address _externalAccount, address _account) {
        require(_externalAccount == _account, Unauthorized);
        _;
    }
    
    modifier onlyByTwo(address _account, address _account2) {
        require(msg.sender == _account || msg.sender == _account2, Unauthorized);
        _;
    }
    
    modifier onlyByMembers(address _caller) {
        require(Util.onlyByMembers(_caller, client, restaurant, deliverymen), Unauthorized);
        _;
    }
    
    modifier atStep(OrderStep _step) {
        require(step == _step, FunctionInvalidAtThisStep);
        _;
    }

    constructor(
        uint256 _id,
        address _client,
        address _restaurant,
        uint256 _deliveryPrice,
        uint256 _total,
        string memory _items,
        string memory _itemsClient
    ) payable {
        id = _id;
        client = _client;
        restaurant = _restaurant;
        step = OrderStep.ORDERED;
        deliveryPrice = _deliveryPrice;
        total = _total;
        timestamp[OrderStep.ORDERED] = block.timestamp;
        items = _items;
        itemsClient = _itemsClient;
        require(msg.value >= total + deliveryPrice, "Insufficient funds to complete an order.");
        payment[_client] += msg.value;
        
        clientCode = Util.random(block.timestamp + 1000, block.difficulty);
        deliverymenCode[0] = Util.random(block.timestamp, block.difficulty);
        deliverymenCode[1] = Util.random(block.timestamp - 33949, block.difficulty);
    }

    // ... (rest of the contract functions remain unchanged)
}
