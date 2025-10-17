// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract V1 {
    uint256 public a;
    uint256 public b;
}

contract V2 is V1 {
    uint256 public c;
    function set(uint256 _a, uint256 _b, uint256 _c) external {
        a=_a;b=_b;c=_c;
    }
    function echidna_storage_order() external view returns (bool) {
        return a >= 0 && b >= 0 && c >= 0;
    }
}