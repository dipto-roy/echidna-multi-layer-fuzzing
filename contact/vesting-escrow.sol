// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract VestingEscrow {
    address public beneficiary;
    uint256 public start;
    uint256 public duration;
    uint256 public released;
    uint256 public total;

    constructor(address _b, uint256 _d) {
        beneficiary = _b;
        start = block.timestamp;
        duration = _d;
        total = 1000 ether;
    }

    function releasable() public view returns (uint256) {
        uint256 elapsed = block.timestamp - start;
        if (elapsed >= duration) return total - released;
        return (total * elapsed) / duration - released;
    }

    function release() external {
        uint256 amt = releasable();
        released += amt;
        // transfer omitted
    }

    function echidna_released_le_total() external view returns (bool) {
        return released <= total;
    }
}
