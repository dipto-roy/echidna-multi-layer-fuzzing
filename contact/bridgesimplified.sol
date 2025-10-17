// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BridgeSimplified {
    mapping(bytes32 => bool) public processed;
    function deposit(bytes32 id) external payable {
        require(msg.value > 0, "amt");
        require(!processed[id], "dup");
        processed[id] = true;
    }

    function echidna_id_not_reused(bytes32 id) external view returns (bool) {
        return processed[id] == true || processed[id] == false;
    }
}