// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import { PoolLens, PoolInfo } from "src/PoolLens.sol";

contract PoolLensTest is Test {
    PoolLens public poolLens;
    address constant pool = 0xc931D9fEFd06A8361d8057501F1EC522cF69c573;

    function setUp() public {
        vm.createSelectFork(vm.envString("RPC_URL"));
        poolLens = new PoolLens();
    }

    function test_getPoolInfo() public view {
        PoolInfo memory info = poolLens.getPoolInfo(pool);
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
        address usdc = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;  // 6
        address shib = 0x95aD61b0a150d79219dCF64E1E6Cc01f0B64C4cE;  // 18
        address wbtc = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;  // 8
        address[] memory tokens = new address[](3);
        tokens[0] = usdc;
        tokens[1] = shib;
        tokens[2] = wbtc;
        poolLens.updateDecimals(tokens);
        assertEq(poolLens.tokenDecimals(usdc), 6);
        assertEq(poolLens.tokenDecimals(shib), 18);
        assertEq(poolLens.tokenDecimals(wbtc), 8);
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
}
