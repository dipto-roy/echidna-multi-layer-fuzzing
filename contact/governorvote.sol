// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract GovernorVotesDemo {
    mapping(address => uint256) public votingPower;
    uint256 public proposalCount;

    function delegate(address to, uint256 amount) external {
        votingPower[to] += amount;
    }

    function propose() external returns (uint256) {
        proposalCount += 1;
        return proposalCount;
    }

    function echidna_nonnegative_power(address who) external view returns (bool) {
        return votingPower[who] >= 0;
    }
}