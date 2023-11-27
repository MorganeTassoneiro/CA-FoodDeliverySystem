// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import './Order.sol';
import './Chain.sol';

struct EncryptedAddress {
    bytes32[] firstHalf;
    bytes32[] secondHalf;
    string encryptedAddressDelivery1;
    string encryptedAddressDelivery2;
    string encryptedItemsDelivery1;
    string encryptedItemsDelivery2;
    uint256 timestamp;
}

contract Storage {
    mapping(uint256 => EncryptedAddress) private encryptedBook;

    function addInformation(uint256 _index, string memory _encryptedAddress, string memory _encryptedItems) public {
        if (encryptedBook[_index].firstHalf.length == 1) {
            encryptedBook[_index].encryptedAddressDelivery1 = _encryptedAddress;
            encryptedBook[_index].encryptedItemsDelivery1 = _encryptedItems;
        } else if (encryptedBook[_index].firstHalf.length == 2) {
            encryptedBook[_index].encryptedAddressDelivery2 = _encryptedAddress;
            encryptedBook[_index].encryptedItemsDelivery2 = _encryptedItems;
        }
    }

    function readInformation(uint256 _index) public view returns (string memory, string memory) {
        if (encryptedBook[_index].firstHalf.length == 1) {
            return (encryptedBook[_index].encryptedAddressDelivery1, encryptedBook[_index].encryptedItemsDelivery1);
        } else {
            return (encryptedBook[_index].encryptedAddressDelivery2, encryptedBook[_index].encryptedItemsDelivery2);
        }
    }

    function addDeliveryman(uint256 _index, bytes32 _firstHalf, bytes32 _secondHalf) external {
        if (encryptedBook[_index].firstHalf.length == 0) {
            encryptedBook[_index].timestamp = block.timestamp;
            encryptedBook[_index].firstHalf.push(_firstHalf);
            encryptedBook[_index].secondHalf.push(_secondHalf);
        } else if (encryptedBook[_index].firstHalf.length == 1) {
            encryptedBook[_index].firstHalf.push(_firstHalf);
            encryptedBook[_index].secondHalf.push(_secondHalf);
        }
    }

    function getDeliveryman(uint256 _index) public view returns (bytes32, bytes32) {
        if (encryptedBook[_index].firstHalf.length == 1) {
            return (encryptedBook[_index].firstHalf[0], encryptedBook[_index].secondHalf[0]);
        } else if (encryptedBook[_index].firstHalf.length == 2) {
            return (encryptedBook[_index].firstHalf[1], encryptedBook[_index].secondHalf[1]);
        } else {
            return (bytes32(0), bytes32(0));
        }
    }
}
