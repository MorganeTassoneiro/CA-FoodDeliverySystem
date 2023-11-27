pragma solidity >=0.7.0 <0.9.0;

library Util {
    struct Item {
        string itemName;
        uint itemQuantity;
        uint256 itemPrice;
    }
    
    function getStepValue(Order.OrderStep _step) external pure returns (string memory) {
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
    
    function onlyByMembers (address _caller, address client, address restaurant, address[] memory deliverymen) external pure returns (bool) {
        if (deliverymen.length == 0 && _caller != client && _caller != restaurant)
            return false;
        else if (deliverymen.length == 1 && _caller != client && _caller != restaurant && _caller != deliverymen[0])
            return false;
        else if (deliverymen.length == 2 && _caller != client && _caller != restaurant && _caller != deliverymen[1])
            return false;
        else
            return true;
    }
}
