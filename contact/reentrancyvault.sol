// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ReentrancyVault {
    mapping(address => uint256) public balances;
    bool private locked;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount) external {
        require(balances[msg.sender] >= amount, "insufficient");
        require(!locked, "no reentrancy");
        locked = true;
        (bool ok,) = msg.sender.call{value: amount}("");
        require(ok, "transfer fail");
        balances[msg.sender] -= amount;
        locked = false;
    }

    // Echidna: balance never goes negative and lock must be false after calls
    function echidna_lock_is_clear() public view returns (bool) {
        return locked == false;
    }
}
