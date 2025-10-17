// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract LotteryCommitReveal {
    bytes32 public commit;
    address public player;
    uint256 public stake;
    bool public revealed;

    function commitHash(bytes32 _c) external payable {
        require(commit == bytes32(0), "set");
        require(msg.value > 0, "stake");
        commit = _c;
        stake = msg.value;
        player = msg.sender;
    }

    function reveal(bytes32 salt, uint256 guess) external {
        require(msg.sender == player, "player");
        require(!revealed, "done");
        require(keccak256(abi.encodePacked(salt, guess)) == commit, "bad");
        revealed = true;
    }

    function echidna_stake_after_commit() external view returns (bool) {
        return (commit == bytes32(0)) || (stake > 0);
    }
}
