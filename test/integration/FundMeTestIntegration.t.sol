// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import {stdError} from "forge-std/StdError.sol";
import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/fund-me/FundMe.sol";
import {FundMeScript} from "../../script/FundMeScript.s.sol";
import {Fund, Withdraw} from "../../script/Interaction.s.sol";

contract FundMeTestIntegration is Test {
    FundMe public fundMe;

    // Init fake user
    address USER = makeAddr("USER");
    uint256 constant ETH_TO_SEND = 0.1 ether;
    uint256 constant INITIAL_BALANCE = 100 ether;
    uint256 constant GAS_PRICE = 20;

    function setUp() public {
        fundMe = new FundMeScript().run();
    }

    function test_UserCanFundInteraction() public {
        Fund fund = new Fund();

        fund.fund(address(fundMe));

        address funder = fundMe.getFunder(0);
        assertEq(funder, msg.sender);
    }

    function test_UserCanWithdrawInteraction() public {
        Fund fund = new Fund();
        Withdraw withdraw = new Withdraw();

        fund.fund(address(fundMe));

        withdraw.withdraw(address(fundMe));

        assertEq(address(fundMe).balance, 0);
    }
}
