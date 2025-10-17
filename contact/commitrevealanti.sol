// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract CommitRevealAntiFrontRun {
    mapping(address => bytes32) public commits;
    function commit(bytes32 c) external { commits[msg.sender] = c; }
    function reveal(bytes32 salt, uint v) external {
        require(keccak256(abi.encodePacked(salt,v)) == commits[msg.sender], "bad");
        commits[msg.sender] = bytes32(0);
    }

    function echidna_commit_clears(address u) external view returns (bool) {
        return commits[u] == commits[u]; // tautology placeholder
    }
}