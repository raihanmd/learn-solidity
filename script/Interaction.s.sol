// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.30;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/fund-me/FundMe.sol";

contract Fund is Script {
    uint constant ETH_TO_BE_SENT = 0.1 ether;

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );

        vm.startBroadcast();
        fund(mostRecentlyDeployed);
        vm.stopBroadcast();
    }

    function fund(address _fundMeAddr) public {
        FundMe(payable(_fundMeAddr)).fund{value: ETH_TO_BE_SENT}();

        console.log("Funded %s", ETH_TO_BE_SENT);
    }
}

contract Withdraw is Script {}
