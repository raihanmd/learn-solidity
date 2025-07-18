// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

import {PriceConsumer} from "./lib/PriceConsumer.sol";

error FundMe__Unauthorized();
error FundMe__UnknownError();
error FundMe__NotEnoughEthSent(string message);

contract FundMe {
    using PriceConsumer for uint256;

    uint256 public constant MINIMUM_USD = 5e18;

    address private immutable i_owner;
    address[] private s_funders;
    mapping(address funder => uint256 amountFunded)
        private s_funderToAmountFunded;

    AggregatorV3Interface private immutable i_priceFeed;

    constructor(address _priceFeed) {
        i_owner = msg.sender;
        i_priceFeed = AggregatorV3Interface(_priceFeed);
    }

    function fund() public payable {
        require(
            // PriceConsumer.getConversionRate(msg.value) >= MINIMUM_USD, //! Before
            msg.value.getConversionRate(i_priceFeed) >= MINIMUM_USD, //* After before, bisa di langsung pake
            FundMe__NotEnoughEthSent("Minimal value worth 5 USD")
        );

        s_funders.push(msg.sender);
        s_funderToAmountFunded[msg.sender] += msg.value;
    }

    function optimizaedWithdraw() public _onlyOwner {
        uint256 fundersLength = s_funders.length;

        for (uint256 i = 0; i < fundersLength; i++) {
            (bool successCall, ) = payable(i_owner).call{
                value: s_funderToAmountFunded[s_funders[i]]
            }("");

            s_funderToAmountFunded[s_funders[i]] = 0;

            require(successCall, FundMe__UnknownError());
        }

        s_funders = new address[](0);
    }

    // gas 87353
    function withdraw() public _onlyOwner {
        // revert() // * Immidiately stop the transaction
        for (uint256 i = 0; i < s_funders.length; i++) {
            // * transfer
            // payable(s_funders[i]).transfer(s_funderToAmountFunded[s_funders[i]]);
            // * send
            // bool success = payable(s_funders[i]).send(
            //     s_funderToAmountFunded[s_funders[i]]
            // );
            // require(success, "Send failed");
            //  * call (lower level stuff), params 2 is returned from func that called in `.call()` params
            (
                bool successCall, // * params 2: `bytes memory data`

            ) = payable(i_owner).call{
                    value: s_funderToAmountFunded[s_funders[i]]
                }("");

            s_funderToAmountFunded[s_funders[i]] = 0;

            require(successCall, FundMe__UnknownError());
        }

        s_funders = new address[](0);
    }

    // * Called when calldata to it is blank
    receive() external payable {
        fund();
    }

    // * Called when calldata to it is not blank, then the function that point to be called is not defined on contract
    fallback() external payable {
        fund();
    }

    function getPriceConsumerVersion() public view returns (uint256) {
        return PriceConsumer.getVersion(i_priceFeed);
    }

    function getFunderToAmountFunded(
        address _funder
    ) public view returns (uint256) {
        return s_funderToAmountFunded[_funder];
    }

    function getFunder(uint256 _index) public view returns (address) {
        return s_funders[_index];
    }

    function getOwner() public view returns (address) {
        return i_owner;
    }

    modifier _onlyOwner() {
        require(msg.sender == i_owner, FundMe__Unauthorized());
        _;
    }
}
