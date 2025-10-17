// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract RateLimitedERC20Mint {
    string public constant name = "RLToken";
    string public constant symbol = "RLT";
    uint8 public constant decimals = 18;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;

    uint256 public lastMint;
    uint256 public interval = 1 days;
    uint256 public mintAmount = 100 ether;

    function mint() external {
        require(block.timestamp >= lastMint + interval, "wait");
        lastMint = block.timestamp;
        totalSupply += mintAmount;
        balanceOf[msg.sender] += mintAmount;
    }

    function echidna_interval_positive() external view returns (bool) {
        return interval > 0;
    }
}
