// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract LendingPoolDemo {
    mapping(address => uint256) public deposits;
    mapping(address => uint256) public borrows;

    function deposit() external payable { deposits[msg.sender] += msg.value; }

    function borrow(uint256 amount) external {
        require(deposits[msg.sender] * 50 / 100 >= amount, "LTV");
        borrows[msg.sender] += amount;
        payable(msg.sender).transfer(amount);
    }

    function repay() external payable {
        require(borrows[msg.sender] >= msg.value, "over");
        borrows[msg.sender] -= msg.value;
    }

    function echidna_health_factor_ok(address u) external view returns (bool) {
        return deposits[u] * 2 >= borrows[u]; // simplistic HF >= 1
    }
}
