// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Storage} from "./Storage.sol";

contract StorageFactory {
    Storage[] storages;

    function newStorage() public {
        storages.push(new Storage());
    }

    function sStore(uint _index, uint256 _number) public {
        storages[_index].store(_number);
    }
}
