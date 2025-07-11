// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {PoolLens, PoolInfo} from "src/PoolLens.sol";

contract PoolLensTest is Test {
    PoolLens public poolLens;

    function setUp() public {
        vm.createSelectFork(vm.envString("RPC_URL"));
        poolLens = new PoolLens();
    }

    function test_isAllowed() public view {
        assertTrue(poolLens.isAllowed(address(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f))); // Uniswap V2
        assertTrue(poolLens.isAllowed(address(0x1F98431c8aD98523631AE4a59f267346ea31F984))); // Uniswap V3
        assertFalse(poolLens.isAllowed(address(0xC0AEe478e3658e2610c5F7A4A2E1777cE9e4f2Ac))); // Sushi V2
    }

    function test_isAllowedPool() public view {
        assertTrue(poolLens.isAllowedPool(address(0xca7c2771D248dCBe09EABE0CE57A62e18dA178c0))); // Uniswap V2
        assertTrue(poolLens.isAllowedPool(address(0x4585FE77225b41b697C938B018E2Ac67Ac5a20c0))); // Uniswap V3
        assertFalse(poolLens.isAllowedPool(address(0x6a091a3406E0073C3CD6340122143009aDac0EDa))); // Sushi V2
        assertFalse(poolLens.isAllowedPool(address(0x48759F220ED983dB51fA7A8C0D2AAb8f3ce4166a))); // Not a pool
    }

    function test_getRate() public view {
        address token = address(0xaea46A60368A7bD060eec7DF8CBa43b7EF41Ad85);
        console.log(poolLens.getRate(token));
    }

    function test_getPoolInfo() public view {
        PoolInfo memory info = poolLens.getPoolInfo(address(0xc931D9fEFd06A8361d8057501F1EC522cF69c573));
        console.log(address(info.token0));
        console.log(address(info.token1));
        console.log(address(info.factory));
        console.log(info.balance0);
        console.log(info.balance1);
    }

    function test_getETHPrice() public view {
        console.log(poolLens.getETHPrice());
    }

    function test_updateDecimals() public {
        address usdc = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48; // 6
        address shib = 0x95aD61b0a150d79219dCF64E1E6Cc01f0B64C4cE; // 18
        address wbtc = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599; // 8
        address[] memory tokens = new address[](3);
        tokens[0] = usdc;
        tokens[1] = shib;
        tokens[2] = wbtc;
        poolLens.updateDecimals(tokens);
        assertEq(poolLens.tokenDecimals(usdc), 6);
        assertEq(poolLens.tokenDecimals(shib), 18);
        assertEq(poolLens.tokenDecimals(wbtc), 8);
    }

    function test_updatePrices() public {
        address usdc = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48; // 6
        address shib = 0x95aD61b0a150d79219dCF64E1E6Cc01f0B64C4cE; // 18
        address wbtc = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599; // 8
        address[] memory tokens = new address[](3);
        tokens[0] = usdc;
        tokens[1] = shib;
        tokens[2] = wbtc;
        poolLens.updatePrices(tokens, 276287000000);
        console.log(poolLens.tokenPrices(usdc));
        console.log(poolLens.tokenPrices(shib));
        console.log(poolLens.tokenPrices(wbtc));
    }

    function test_batchInspect() public {
        address[] memory pools = new address[](3);
        pools[0] = address(0x61cE73f7915d2A65dE70cAe38b051727A81306C8);
        pools[1] = address(0x9e0905249CeEFfFB9605E034b534544684A58BE6);
        pools[2] = address(0x795065dCc9f64b5614C407a6EFDC400DA6221FB0);
        (PoolInfo[] memory infos, int256 ethPrice) = poolLens.batchInspect(pools);
        for (uint256 i = 0; i < infos.length; i++) {
            console.log(address(infos[i].token0));
            console.log(address(infos[i].token1));
            console.log(address(infos[i].factory));
            console.log(infos[i].balance0);
            console.log(infos[i].balance1);
            console.log(infos[i].decimals0);
            console.log(infos[i].decimals1);
        }
        console.log(ethPrice);
    }

    function test_batchJudge() public {
        address[] memory pools = new address[](4);
        pools[0] = address(0x8b7634e648C8282071bc7B6254f2A854baC77a4c); // expect -1 (Insufficient Liquidity)
        pools[1] = address(0x9e0905249CeEFfFB9605E034b534544684A58BE6); // expect 1 (HEX-WETH poolValue: 3.9e5)
        pools[2] = address(0x795065dCc9f64b5614C407a6EFDC400DA6221FB0); // expect 0 (Invalid protocol: sushi v2)
        pools[3] = address(0x48759F220ED983dB51fA7A8C0D2AAb8f3ce4166a); // expect 0 (Not a pool)
        int8[] memory results = poolLens.batchJudge(pools, 1000);
        for (uint256 i = 0; i < results.length; i++) {
            console.log(results[i]);
        }
    }

    function test_debug() public {
        address[] memory pools = new address[](1);
        pools[0] = address(0x48759F220ED983dB51fA7A8C0D2AAb8f3ce4166a);

        int8[] memory results = poolLens.batchJudge(pools, 1);
        for (uint256 i = 0; i < results.length; i++) {
            console.log(results[i]);
        }
    }
}
