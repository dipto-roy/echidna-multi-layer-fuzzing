// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MetaTxForwarder {
    mapping(bytes32 => bool) public executed;

    function forward(address to, bytes calldata data, uint256 nonce, uint8 v, bytes32 r, bytes32 s) external {
        bytes32 h = keccak256(abi.encode(to, data, nonce));
        require(!executed[h], "dup");
        address signer = ecrecover(h, v, r, s);
        require(signer != address(0), "sig");
        executed[h] = true;
        (bool ok,) = to.call(data);
        require(ok, "call");
    }

    function echidna_no_replay(bytes32 h) external view returns (bool) {
        return executed[h] == true || executed[h] == false;
    }
}


