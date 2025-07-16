// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import {PriceConsumer} from "./lib/PriceConsumer.sol";

error Unauthorized();
error Forbidden(string message);

contract FundMe {
    using PriceConsumer for uint256;

    uint256 constant MINIMUM_USD = 5e18;

    address immutable i_owner;
    address[] funders;
    mapping(address funder => uint256 amountFunded) public funderToAmountFunded;

    constructor() {
        i_owner = msg.sender;
    }

    function fund() public payable {
        require(
            // PriceConsumer.getConversionRate(msg.value) >= MINIMUM_USD, //! Before
            msg.value.getConversionRate() >= MINIMUM_USD, //* After before, bisa di langsung pake
            Forbidden("Minimal value worth 5 USD")
        );

        funders.push(msg.sender);
        funderToAmountFunded[msg.sender] += msg.value;
    }

    function withdraw() public _onlyOwner {
        // revert() // * Immidiately stop the transaction
        for (uint256 i = 0; i < funders.length; i++) {
            funderToAmountFunded[funders[i]] = 0;
            // * transfer
            // payable(funders[i]).transfer(funderToAmountFunded[funders[i]]);
            // * send
            // bool success = payable(funders[i]).send(
            //     funderToAmountFunded[funders[i]]
            // );
            // require(success, "Send failed");
            //  * call (lower level stuff), params 2 is returned from func that called in `.call()` params
            (
                bool successCall, // * params 2: `bytes memory data`

            ) = payable(funders[i]).call{
                    value: funderToAmountFunded[funders[i]]
                }("");
            require(successCall, "Call failed");
        }

        funders = new address[](0);
    }

    // * Called when calldata to it is blank
    receive() external payable {
        fund();
    }

    // * Called when calldata to it is not blank, then the function that point to be called is not defined on contract
    fallback() external payable {
        fund();
    }

    modifier _onlyOwner() {
        require(msg.sender == i_owner, Unauthorized());
        _;
    }
}
