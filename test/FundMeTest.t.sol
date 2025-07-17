// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import {stdError} from "forge-std/StdError.sol";
import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/fund-me/FundMe.sol";
import {FundMeScript} from "../script/FundMeScript.s.sol";

contract FundMeTest is Test {
    FundMe public fundMe;

    function setUp() public {
        fundMe = new FundMeScript().run();
    }

    function test_MinimumUSD() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
        console.log(fundMe.MINIMUM_USD());
    }

    function test_OwnerIsMsgSender() public view {
        assertEq(fundMe.i_owner(), msg.sender);
    }

    function test_PriceConsumerVersion() public view {
        assertEq(fundMe.getPriceConsumerVersion(), 4);
    }
}
