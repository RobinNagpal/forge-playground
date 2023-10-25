// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "v4-core/interfaces/IPoolManager.sol";
import "v4-core/libraries/FullMath.sol";
import "v4-core/libraries/FixedPoint96.sol";
import "v4-core/libraries/TickMath.sol";
import "v4-core/libraries/SqrtPriceMath.sol";
import "periphery-next/libraries/LiquidityAmounts.sol";

contract LiquidityCalculator {

    function getLiquidityForScenario1() public pure returns (uint128) {
        // Scenario:
        //
        // You believe the price of WETH in terms of USDC is going to rise and want to provide liquidity in a particular price range.
        // The current price of WETH in terms of USDC is 2500 (i.e., 1 WETH = 2500 USDC).
        // You want to provide liquidity in the price range: 1 WETH = 2600 USDC to 1 WETH = 2800 USDC.
        // You're willing to deposit 1 WETH and 2700 USDC into the pool (we're picking 2700 as a value within our desired price range).

        // Calculation of sqrtRatioX96:
        // For our example, sqrtRatioX96 would be the square root of the price (2500) multiplied by 2^96.

        // Calculation of sqrtRatioAX96 and sqrtRatioBX96:
        // sqrtRatioAX96 would be the square root of 2600 multiplied by 2^96.
        // sqrtRatioBX96 would be the square root of 2800 multiplied by 2^96.
        // Code to call getLiquidityForAmounts:
        uint160 sqrtRatioX96 = uint160(sqrt(2500) * (1 << 96));
        uint160 sqrtRatioAX96 = uint160(sqrt(2600) * (1 << 96));
        uint160 sqrtRatioBX96 = uint160(sqrt(2800) * (1 << 96));
        uint256 amount0 = 1 ether;  // Assuming WETH has 18 decimals
        uint256 amount1 = 2700 * 1e6; // Assuming USDC has 6 decimals

        uint128 liquidity = LiquidityAmounts.getLiquidityForAmounts(sqrtRatioX96, sqrtRatioAX96, sqrtRatioBX96, amount0, amount1);
        return liquidity;
    }

    function sqrt(uint256 x) internal pure returns (uint256) {
        if (x == 0) return 0;
        uint256 z = x;
        uint256 y = (z + 1) / 2;
        while (y < z) {
            z = y;
            y = (z + x / z) / 2;
        }
        return z;
    }



    uint256 constant public Q96 = 2**96;

    function calculateTick(uint256 priceRatio, int24 fee) external pure returns (int24 tick) {
        int256 lnPriceRatio = int256(priceRatio) * int256(Q96) * 2 / int256(Q96); // Convert price ratio to logarithmic scale
        int256 tickSpacing = int256(160) - int256(fee) * int256(32); // Calculate tick spacing based on fee level
        tick = int24(lnPriceRatio / tickSpacing); // Calculate the tick position
    }
}
