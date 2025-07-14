// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Storage} from "./Storage.sol";

contract StorageInherit is Storage {
    function store(uint256 _number) public override {
        myFavoriteNumber = _number / 2;
    }
}
