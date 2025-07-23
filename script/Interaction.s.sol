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

        fund(mostRecentlyDeployed);
    }

    function fund(address _fundMeAddr) public {
        vm.startBroadcast();
        FundMe(payable(_fundMeAddr)).fund{value: ETH_TO_BE_SENT}();
        vm.stopBroadcast();

        console.log("Funded %s", ETH_TO_BE_SENT);
    }
}

contract Withdraw is Script {
    uint constant ETH_TO_BE_SENT = 0.1 ether;

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );

        withdraw(mostRecentlyDeployed);
    }

    function withdraw(address _fundMeAddr) public {
        vm.startBroadcast();
        FundMe(payable(_fundMeAddr)).withdraw();
        vm.stopBroadcast();

        console.log("Funded %s", ETH_TO_BE_SENT);
    }
}
