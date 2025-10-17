// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract FeeOnTransferToken {
    mapping(address => uint256) public balanceOf;
    uint256 public totalSupply;
    uint256 public feeBps = 100; // 1%

    constructor() { totalSupply = 100_000 ether; balanceOf[msg.sender] = totalSupply; }

    function transfer(address to, uint256 amount) external returns (bool) {
        require(balanceOf[msg.sender] >= amount, "bal");
        uint256 fee = (amount * feeBps) / 10_000;
        uint256 out = amount - fee;
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += out;
        totalSupply -= fee; // burned
        return true;
    }

    function echidna_fee_bps_bounds() external view returns (bool) {
        return feeBps <= 1_000; // <=10%
    }
}