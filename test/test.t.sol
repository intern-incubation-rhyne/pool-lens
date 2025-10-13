// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";

contract SomeTest is Test {
    bytes32 _data = 0x04010200000000000000000071523d0f655b41e805cec45b17163f528b59b820;
    bytes32 _marketId = 0xf0aa04835adf4beacddd933e49e6e08ffd37014751dc3f7d167f73cb64213d00;

    function test_oracle() public view returns (address oracle) {
        oracle = address(uint160(uint256(_data)));
        console.log(oracle); // Remove console.log for pure function
    }

    function test_getQuestionId() public view returns (bytes32 _questionIndex) {
        _questionIndex = bytes32(uint256(1));
        bytes32 questionId;
        unchecked {
            questionId = bytes32(uint256(_marketId) + uint256(_questionIndex));
        }
        console.logBytes32(questionId); // Note: console.log doesn't support bytes32 directly
    }
}
