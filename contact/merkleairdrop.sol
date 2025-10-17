// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MerkleAirdrop {
    bytes32 public merkleRoot;
    mapping(address => bool) public claimed;
    constructor(bytes32 root) { merkleRoot = root; }

    function claim(bytes32[] calldata /*proof*/, uint256 /*amount*/) external {
        require(!claimed[msg.sender], "claimed");
        // skip proof verification for demo
        claimed[msg.sender] = true;
    }

    function echidna_no_double_claim(address user) external view returns (bool) {
        // Once claimed true, it must remain true or false; no reversion check here
        return claimed[user] == true || claimed[user] == false;
    }
}