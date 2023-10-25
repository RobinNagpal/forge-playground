// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {LiquidityCalculator} from "../src/LiquidityCalculator.sol";

contract LiquidityCalculatorTest is Test {
    LiquidityCalculator public liquidityCalculator;

    function setUp() public {
        liquidityCalculator = new LiquidityCalculator();
    }


    function test_LiquidityForScenario1() public {
        uint128 liquidity = liquidityCalculator.getLiquidityForScenario1();
        assertEq(liquidity, 1.3e21);
    }

    function test_calculateTick() public {
        int24 sqrt = liquidityCalculator.calculateTick(2500, 5000);
        assertEq(int24(50), int24(50));
    }
}
