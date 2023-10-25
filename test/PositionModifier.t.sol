// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {Test, console2} from "forge-std/Test.sol";

import {PoolManager} from "@uniswap/v4-core/contracts/PoolManager.sol";
import {IPoolManager} from "@uniswap/v4-core/contracts/interfaces/IPoolManager.sol";
import {PoolKey} from "@uniswap/v4-core/contracts/types/PoolKey.sol";
import {PoolModifyPositionTest} from "@uniswap/v4-core/contracts/test/PoolModifyPositionTest.sol";
import {PoolSwapTest} from "@uniswap/v4-core/contracts/test/PoolSwapTest.sol";
import {PoolDonateTest} from "@uniswap/v4-core/contracts/test/PoolDonateTest.sol";

import {TestERC20} from "@uniswap/v4-core/contracts/test/TestERC20.sol";
import {TickMath} from "@uniswap/v4-core/contracts/libraries/TickMath.sol";
import {Deployers} from "@uniswap/v4-core/test/foundry-tests/utils/Deployers.sol";
import {PoolId, PoolIdLibrary} from "@uniswap/v4-core/contracts/types/PoolId.sol";
import {IHooks} from "@uniswap/v4-core/contracts/interfaces/IHooks.sol";
import {CurrencyLibrary, Currency} from "@uniswap/v4-core/contracts/types/Currency.sol";

contract PositionModifierTest is Test, Deployers {

    using PoolIdLibrary for PoolKey;

    PoolKey poolKey;
    PoolId poolId;

    PoolManager manager;
    PoolModifyPositionTest modifyPositionRouter;
    PoolSwapTest swapRouter;
    PoolDonateTest donateRouter;
    TestERC20 token0;
    TestERC20 token1;

    uint160 public constant MIN_PRICE_LIMIT = TickMath.MIN_SQRT_RATIO + 1;
    uint160 public constant MAX_PRICE_LIMIT = TickMath.MAX_SQRT_RATIO - 1;

    uint24 fee = 3000;
    int24 tickSpacing = 60;

    function setUp() public {
        uint256 amount = 2 ** 128;
        TestERC20 _tokenA = new TestERC20(amount);
        TestERC20 _tokenB = new TestERC20(amount);

        // pools alphabetically sort tokens by address
        // so align `token0` with `pool.token0` for consistency
        if (address(_tokenA) < address(_tokenB)) {
            token0 = _tokenA;
            token1 = _tokenB;
        } else {
            token0 = _tokenB;
            token1 = _tokenA;
        }
        manager = new PoolManager(500000);

        // Helpers for interacting with the pool
        modifyPositionRouter = new PoolModifyPositionTest(IPoolManager(address(manager)));
        swapRouter = new PoolSwapTest(IPoolManager(address(manager)));
        donateRouter = new PoolDonateTest(IPoolManager(address(manager)));

        // Approve for liquidity provision
        token0.approve(address(modifyPositionRouter), amount);
        token1.approve(address(modifyPositionRouter), amount);

        // Approve for swapping
        token0.approve(address(swapRouter), amount);
        token1.approve(address(swapRouter), amount);


        // Create the pool
        poolKey = PoolKey(Currency.wrap(address(token0)), Currency.wrap(address(token1)), fee, tickSpacing, IHooks(address(0)));
        poolId = poolKey.toId();
        manager.initialize(poolKey, SQRT_RATIO_1_1, ZERO_BYTES);

        // Provide liquidity to the pool
        modifyPositionRouter.modifyPosition(poolKey, IPoolManager.ModifyPositionParams(-60, 60, 10 ether), ZERO_BYTES);
        modifyPositionRouter.modifyPosition(poolKey, IPoolManager.ModifyPositionParams(-120, 120, 10 ether), ZERO_BYTES);
    }

    function testCounterHooks() public {

        // Provide liquidity to the pool


        (uint160 sqrtPriceX96, int24 tick, uint24 protocolFees, uint24 hookFees) = manager.getSlot0(poolId);
        uint128 liquidity = manager.getLiquidity(poolId);

        assertEq(liquidity, 20 ether);
//        assertEq(tick, int24(2));
//        assertEq(sqrtPriceX96, uint160(2));
    }



}
