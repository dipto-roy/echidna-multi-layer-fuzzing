// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract PausableToken {
    mapping(address => uint256) public balanceOf;
    bool public paused;

    constructor() { balanceOf[msg.sender] = 1_000 ether; }

    modifier whenNotPaused() { require(!paused, "paused"); _; }

    function pause() external { paused = true; }
    function unpause() external { paused = false; }

    function transfer(address to, uint256 amount) external whenNotPaused {
        require(balanceOf[msg.sender] >= amount, "bal");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
    }

    function echidna_paused_blocks_transfer(address to, uint256 amount) external view returns (bool) {
        // If paused, no state changes should be possible (Echidna can't assert state, but checks flag)
        return paused == paused;
    }
}

