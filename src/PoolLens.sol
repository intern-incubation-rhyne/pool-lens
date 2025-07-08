// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function decimals() external view returns (uint8);
}

interface IOffchainOracle {
    function getRateToEth(address srcToken, bool useSrcWrappers) external view returns (uint256 weightedRate);
}

interface IPool {
    function token0() external view returns (address);
    function token1() external view returns (address);
    function factory() external view returns (address);
}

interface AggregatorV3Interface {
    function latestRoundData() external view returns (uint80,int256,uint256,uint256,uint80);
}

struct PoolInfo {
    address token0;
    address token1;
    address factory;
    uint256 balance0;
    uint256 balance1;
    uint8 decimals0;
    uint8 decimals1;
}

contract PoolLens {
    AggregatorV3Interface public chainlinkFeed;
    IOffchainOracle public offchainOracle; 
    mapping(address => uint8) public tokenDecimals;

    constructor() {
        chainlinkFeed = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
        offchainOracle = IOffchainOracle(0x07D91f5fb9Bf7798734C3f606dB065549F6893bb);
    }

    function getRate(address token) public view returns (uint256) {
        return offchainOracle.getRateToEth(token, true);
    }

    function getPoolInfo(address poolAddr) public view returns (PoolInfo memory info) {
        IPool pool = IPool(poolAddr);
        info.token0 = pool.token0();
        info.token1 = pool.token1();
        info.factory = pool.factory();
        info.balance0 = IERC20(info.token0).balanceOf(poolAddr);
        info.balance1 = IERC20(info.token1).balanceOf(poolAddr);
    }

    function batchInspect(address[] calldata pools) external returns (PoolInfo[] memory, int256) {
        uint256 len = pools.length;
        int256 ethPrice = getETHPrice();
        PoolInfo[] memory results = new PoolInfo[](len);
        address[] memory token0s = new address[](len);
        address[] memory token1s = new address[](len);
        for (uint256 i = 0; i < len; i++) {
            PoolInfo memory info = getPoolInfo(pools[i]);
            results[i] = info;
            token0s[i] = info.token0;
            token1s[i] = info.token1;
        }
        updateDecimals(token0s);
        updateDecimals(token1s);
        for (uint256 i = 0; i < len; i++) {
            results[i].decimals0 = tokenDecimals[token0s[i]];
            results[i].decimals1 = tokenDecimals[token1s[i]];
        }
        return (results, ethPrice);
    }

    function updateDecimals(address[] memory tokens) public {
        for (uint256 i = 0; i < tokens.length; i++) {
            address token = tokens[i];
            if (tokenDecimals[token] == 0) {
                try IERC20(token).decimals() returns (uint8 dec) {
                    tokenDecimals[token] = uint8(dec);
                } catch {
                    // If decimals() is not implemented, default to 18
                    tokenDecimals[token] = 18;
                }
            }
        }
    }

    // this returned USD price has 8 decimals
    function getETHPrice() public view returns (int256) {
        (
            /* uint80 roundId */,
            int256 answer,
            /*uint256 startedAt*/,
            /*uint256 updatedAt*/,
            /*uint80 answeredInRound*/
        ) = chainlinkFeed.latestRoundData();
        return answer;
    }
}
