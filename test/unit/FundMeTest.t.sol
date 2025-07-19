// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import {stdError} from "forge-std/StdError.sol";
import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/fund-me/FundMe.sol";
import {FundMeScript} from "../../script/FundMeScript.s.sol";

contract FundMeTest is Test {
    FundMe public fundMe;

    // Init fake user
    address USER = makeAddr("USER");
    uint256 constant ETH_TO_SEND = 0.1 ether;
    uint256 constant INITIAL_BALANCE = 100 ether;
    uint256 constant GAS_PRICE = 20;

    function setUp() public {
        fundMe = new FundMeScript().run();

        vm.deal(USER, INITIAL_BALANCE);
    }

    function test_MinimumUSD() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
        console.log(fundMe.MINIMUM_USD());
    }

    function test_OwnerIsMsgSender() public view {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    // function test_PriceConsumerVersion() public view {
    //     assertEq(fundMe.getPriceConsumerVersion(), 4);
    // }

    function test_FundFailsWithoutEnoughEthSend() public {
        vm.expectRevert();

        fundMe.fund{value: 1e8}();
    }

    function test_FundSuccessWithMinimumEthSend() public fund {
        uint256 amountFunded = fundMe.getFunderToAmountFunded(USER);
        address funder = fundMe.getFunder(0);

        assertEq(funder, USER);
        assertEq(amountFunded, ETH_TO_SEND);
    }

    function test_DefaultTxShouldBeCallFundFunction() public {
        vm.prank(USER);
        (bool success, ) = payable(address(fundMe)).call{value: ETH_TO_SEND}(
            ""
        );

        assertEq(success, true);

        uint256 amountFunded = fundMe.getFunderToAmountFunded(USER);
        address funder = fundMe.getFunder(0);

        assertEq(funder, USER);
        assertEq(amountFunded, ETH_TO_SEND);
    }

    function test_DefaultTxWithDataShouldBeCallFundFunction() public {
        vm.prank(USER);
        (bool success, ) = payable(address(fundMe)).call{value: ETH_TO_SEND}(
            "0x1234"
        );

        assertEq(success, true);

        uint256 amountFunded = fundMe.getFunderToAmountFunded(USER);
        address funder = fundMe.getFunder(0);

        assertEq(funder, USER);
        assertEq(amountFunded, ETH_TO_SEND);
    }

    function test_WithdrawSuccess() public fund {
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.prank(fundMe.getOwner());
        vm.txGasPrice(GAS_PRICE);
        fundMe.withdraw();

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
        assertEq(0, endingFundMeBalance);
    }

    function test_WithdrawWithMultipleFunds() public {
        uint160 funders = 100;
        for (uint160 i = 0; i < funders; i++) {
            // hoax() do vm.prank() with vm.deal()
            hoax(address(i), INITIAL_BALANCE);
            fundMe.fund{value: ETH_TO_SEND}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
        assertEq(0, endingFundMeBalance);
    }

    function test_WithdrawWithMultipleFunds_Optimized() public {
        uint160 funders = 100;
        for (uint160 i = 0; i < funders; i++) {
            hoax(address(i), INITIAL_BALANCE);
            fundMe.fund{value: ETH_TO_SEND}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.optimizaedWithdraw();
        vm.stopPrank();

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
        assertEq(0, endingFundMeBalance);
    }

    modifier fund() {
        vm.prank(USER); // The next line tx will be sent by `USER`
        fundMe.fund{value: ETH_TO_SEND}();
        _;
    }
}
