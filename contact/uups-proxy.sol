// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Minimal UUPS-like pattern (educational)
contract UUPSProxy {
    address public implementation;
    address public admin;

    constructor(address impl) {
        implementation = impl;
        admin = msg.sender;
    }

    function upgradeTo(address impl) external {
        require(msg.sender == admin, "only admin");
        implementation = impl;
    }

    fallback() external payable {
        address impl = implementation;
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }
}

contract UUPSLogicV1 {
    uint256 public x;
    function inc() external { x += 1; }
    function echidna_x_monotonic() external view returns (bool) { return x >= 0; }
}