// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "@chainlink/contracts/src/v0.8/shared/mocks/MockV3Aggregator.sol";

struct NetworkConfig {
    address priceFeed;
}

contract HelperConfig is Script {
    NetworkConfig public activeNetworkConfig;

    uint256 constant SEPOLIA_CHAIN_ID = 11155111;
    uint8 constant ETH_DECIMAL = 8;
    int256 constant ETH_PRICE = 2500e8;

    constructor() {
        if (block.chainid == SEPOLIA_CHAIN_ID) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else {
            activeNetworkConfig = getAnvilConfig();
        }
    }

    function getSepoliaEthConfig() internal pure returns (NetworkConfig memory) {
        return NetworkConfig({priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
    }

    function getAnvilConfig() internal returns (NetworkConfig memory) {
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }

        vm.startBroadcast();
        MockV3Aggregator mockV3Aggregator = new MockV3Aggregator(ETH_DECIMAL, ETH_PRICE);
        vm.stopBroadcast();

        return NetworkConfig({priceFeed: address(mockV3Aggregator)});
    }
}
