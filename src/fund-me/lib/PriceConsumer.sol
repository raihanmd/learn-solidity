// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConsumer {
    address private constant ETH_USD_PAIR_ADDRESS =
        0x694AA1769357215DE4FAC081bf1f309aDC325306;

    function getPrice() internal view returns (uint256) {
        (, int256 price, , , ) = AggregatorV3Interface(ETH_USD_PAIR_ADDRESS)
            .latestRoundData();
        return uint256(price * 1e10);
    }

    function getConversionRate(
        uint256 _ethAmount
    ) internal view returns (uint256) {
        uint256 ethPrice = getPrice();
        return (_ethAmount * ethPrice) / 1e18;
    }
}
