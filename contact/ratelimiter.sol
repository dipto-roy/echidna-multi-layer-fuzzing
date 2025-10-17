// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract RateLimiter {
    uint256 public last;
    uint256 public minDelay = 30 seconds;

    function ping() external {
        require(block.timestamp >= last + minDelay, "rate");
        last = block.timestamp;
    }

    function echidna_minDelay_reasonable() external view returns (bool) {
        return minDelay >= 1;
    }
}

