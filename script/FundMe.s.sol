// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {FundMe} from "../src/fund-me/FundMe.sol";

contract FundMeScript is Script {
    FundMe public fundMe;

    function setUp() public {}

    function run() public returns (FundMe) {
        vm.startBroadcast();

        fundMe = new FundMe();

        vm.stopBroadcast();

        return fundMe;
    }
}
