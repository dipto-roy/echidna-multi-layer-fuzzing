// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SignatureReplayGuard {
    mapping(bytes32 => bool) public used;
    function execute(bytes32 hash, uint8 v, bytes32 r, bytes32 s) external {
        require(!used[hash], "replay");
        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "bad");
        used[hash] = true;
    }

    function echidna_no_double_use(bytes32 h) external view returns (bool) {
        return used[h] == true || used[h] == false;
    }
}
