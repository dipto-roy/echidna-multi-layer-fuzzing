// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Ownable2StepDemo {
    address public owner;
    address public pendingOwner;

    constructor() { owner = msg.sender; }

    function transferOwnership(address newOwner) external {
        require(msg.sender == owner, "owner");
        pendingOwner = newOwner;
    }

    function acceptOwnership() external {
        require(msg.sender == pendingOwner, "pending");
        owner = pendingOwner;
        pendingOwner = address(0);
    }

    function echidna_owner_not_zero_after_accept() external view returns (bool) {
        return owner != address(0);
    }
}
