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
    function latestRoundData() external view returns (uint80, int256, uint256, uint256, uint80);
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

event Evaluate(address indexed pool, uint256 poolValue, uint256 tokne0Price, uint256 token1Price);

contract PoolLens {
    address constant CHAINLINK_FEED = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;
    address constant OFFCHAIN_ORACLE = 0x07D91f5fb9Bf7798734C3f606dB065549F6893bb;
    address constant UNISWAP_V2 = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address constant UNISWAP_V3 = 0x1F98431c8aD98523631AE4a59f267346ea31F984;
    mapping(address => uint8) public tokenDecimals;
    mapping(address => uint256) public tokenPrices; // This price is USD per 1e44 units

    function isAllowed(address factory) public pure returns (bool) {
        if (factory == UNISWAP_V2 || factory == UNISWAP_V3) {
            return true;
        } else {
            return false;
        }
    }

    /// @notice This Rate is the WEI amount that 1e18 minimal token units equal to
    function getRate(address token) public view returns (uint256) {
        return IOffchainOracle(OFFCHAIN_ORACLE).getRateToEth(token, true);
    }

    function getPoolInfo(address poolAddr) public view returns (PoolInfo memory info) {
        IPool pool = IPool(poolAddr);
        info.token0 = pool.token0();
        info.token1 = pool.token1();
        info.factory = pool.factory();
        info.balance0 = IERC20(info.token0).balanceOf(poolAddr);
        info.balance1 = IERC20(info.token1).balanceOf(poolAddr);
    }

    /// @notice this Price is in 1e-8 USD per ETH
    function getETHPrice() public view returns (int256) {
        (
            /* uint80 roundId */
            ,
            int256 answer,
            /*uint256 startedAt*/
            ,
            /*uint256 updatedAt*/
            ,
            /*uint80 answeredInRound*/
        ) = AggregatorV3Interface(CHAINLINK_FEED).latestRoundData();
        return answer;
    }

    function updateDecimals(address[] memory tokens) public {
        for (uint256 i = 0; i < tokens.length; i++) {
            address token = tokens[i];
            if (token == address(0)) continue;
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

    /// @notice This price is USD per 1e44 units
    function updatePrices(address[] memory tokens, int256 ethPrice) public {
        IOffchainOracle offchainOracle = IOffchainOracle(OFFCHAIN_ORACLE);
        uint256 len = tokens.length;
        for (uint256 i = 0; i < len; i++) {
            address token = tokens[i];
            if (token == address(0)) continue;
            uint256 rate = offchainOracle.getRateToEth(token, true);
            require(ethPrice >= 0, "Invalid ethPrice: must be non-negative");
            tokenPrices[token] = rate * uint256(ethPrice);
        }
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

        address[] memory uniqueAddresses = unique(token0s, token1s);
        updateDecimals(uniqueAddresses);
        for (uint256 i = 0; i < len; i++) {
            results[i].decimals0 = tokenDecimals[token0s[i]];
            results[i].decimals1 = tokenDecimals[token1s[i]];
        }
        return (results, ethPrice);
    }

    function batchJudge(address[] calldata pools, uint256 USDThreshold) public returns (int8[] memory) {
        USDThreshold = USDThreshold * 1e44;
        uint256 len = pools.length;
        int8[] memory results = new int8[](len);
        int256 ethPrice = getETHPrice();
        PoolInfo[] memory poolInfos = new PoolInfo[](len);
        address[] memory token0s = new address[](len);
        address[] memory token1s = new address[](len);
        for (uint256 i = 0; i < len; i++) {
            PoolInfo memory info = getPoolInfo(pools[i]);
            poolInfos[i] = info;
            if (isAllowed(info.factory)) {
                token0s[i] = info.token0;
                token1s[i] = info.token1;
            }
        }

        address[] memory uniqueTokens = unique(token0s, token1s);
        updateDecimals(uniqueTokens);
        updatePrices(uniqueTokens, ethPrice);

        for (uint256 i = 0; i < len; i++) {
            poolInfos[i].decimals0 = tokenDecimals[token0s[i]];
            poolInfos[i].decimals1 = tokenDecimals[token1s[i]];
        }

        for (uint256 i = 0; i < len; i++) {
            PoolInfo memory info = poolInfos[i];
            if (!isAllowed(info.factory)) {
                results[i] = 0;
            } else {
                uint256 tokne0Price = tokenPrices[info.token0];
                uint256 token1Price = tokenPrices[info.token1];
                uint256 value = info.balance0 * tokne0Price + info.balance1 * token1Price;
                emit Evaluate(pools[i], value, tokne0Price, token1Price);
                if (value >= USDThreshold) {
                    results[i] = 1;
                } else {
                    results[i] = -1;
                }
            }
        }
        return results;
    }

    /// @notice Takes two address arrays and returns a uniqued address array (no duplicates)
    function unique(address[] memory arr1, address[] memory arr2) public pure returns (address[] memory) {
        uint256 len1 = arr1.length;
        uint256 len2 = arr2.length;
        address[] memory temp = new address[](len1 + len2);
        uint256 count = 0;
        // Add all from arr1
        for (uint256 i = 0; i < len1; i++) {
            temp[count++] = arr1[i];
        }
        // Add from arr2 if not already in arr1
        for (uint256 j = 0; j < len2; j++) {
            address addr = arr2[j];
            bool found = false;
            for (uint256 k = 0; k < len1; k++) {
                if (arr1[k] == addr) {
                    found = true;
                    break;
                }
            }
            if (!found) {
                temp[count++] = addr;
            }
        }
        // Copy to result array of correct size
        address[] memory result = new address[](count);
        for (uint256 i = 0; i < count; i++) {
            result[i] = temp[i];
        }
        return result;
    }
}
