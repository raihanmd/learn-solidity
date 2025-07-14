// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./Storage.sol";

contract StorageFactory {
    Storage myStorage;

    function initalize() public {
        myStorage = new Storage();
    }
}
