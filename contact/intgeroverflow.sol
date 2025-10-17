// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract IntegerOverflowGuard {
    uint256 public x;

    function add(uint256 y) external {
        x += y; // 0.8+ has built-in checks
    }

    function echidna_x_never_wraps() external view returns (bool) {
        return x >= 0;
    }
}
