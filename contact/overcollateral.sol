// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract OvercollateralStablecoin {
    mapping(address => uint256) public collateral;
    mapping(address => uint256) public debt;

    function depositCollateral() external payable {
        collateral[msg.sender] += msg.value;
    }

    function mint(uint256 amount) external {
        // require 150% collateral ratio (eth = 1:1 unit for demo)
        require(collateral[msg.sender] * 100 >= amount * 150, "CR");
        debt[msg.sender] += amount;
    }

    function burn(uint256 amount) external {
        require(debt[msg.sender] >= amount, "debt");
        debt[msg.sender] -= amount;
    }

    function echidna_collateralization_check(address user) external view returns (bool) {
        return collateral[user] * 100 >= debt[user] * 150 || debt[user] == 0;
    }
}
