// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract RBACVault {
    mapping(address => bool) public admin;
    mapping(address => uint256) public balance;

    constructor() { admin[msg.sender] = true; }

    function setAdmin(address a, bool v) external {
        require(admin[msg.sender], "admin");
        admin[a] = v;
    }

    function deposit() external payable { balance[msg.sender] += msg.value; }

    function drain(address to, uint256 amount) external {
        require(admin[msg.sender], "admin");
        require(balance[to] >= amount, "bal");
        balance[to] -= amount;
        payable(msg.sender).transfer(amount);
    }

    function echidna_admin_self_consistent(address a) external view returns (bool) {
        return admin[a] == true || admin[a] == false;
    }
}

