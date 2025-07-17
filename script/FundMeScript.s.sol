// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {FundMe} from "../src/fund-me/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract FundMeScript is Script {
    FundMe public fundMe;
    HelperConfig public helperConfig;

    function setUp() public {}

    function run() public returns (FundMe) {
        helperConfig = new HelperConfig();

        vm.startBroadcast();

        fundMe = new FundMe(helperConfig.activeNetworkConfig()); // auto access [0] in struct if struct field only 1 inside

        vm.stopBroadcast();

        return fundMe;
    }
}
