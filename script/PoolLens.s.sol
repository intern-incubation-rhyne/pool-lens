// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/PoolLens.sol"; // your contract

contract Deploy is Script {
    function run() external {
        vm.startBroadcast();
        new PoolLens(); // constructor params if any
        vm.stopBroadcast();
    }
}
