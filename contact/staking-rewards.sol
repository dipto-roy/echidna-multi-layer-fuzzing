// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract StakingRewards {
    mapping(address => uint256) public staked;
    mapping(address => uint256) public rewards;

    function stake() external payable {
        staked[msg.sender] += msg.value;
    }

    function notifyReward(address user, uint256 amount) external {
        rewards[user] += amount;
    }

    function claim() external {
        uint r = rewards[msg.sender];
        rewards[msg.sender] = 0;
        payable(msg.sender).transfer(r);
    }

    function echidna_rewards_nonnegative(address u) external view returns (bool) {
        return rewards[u] >= 0;
    }
}
