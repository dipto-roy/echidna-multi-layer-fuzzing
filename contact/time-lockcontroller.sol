// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract TimelockControllerDemo {
    mapping(bytes32 => uint256) public eta;
    uint256 public delay = 2 days;
    address public admin = msg.sender;

    function queue(bytes32 id) external {
        require(msg.sender == admin, "admin");
        eta[id] = block.timestamp + delay;
    }
    function execute(bytes32 id) external {
        require(block.timestamp >= eta[id], "not ready");
        eta[id] = 0;
    }

    function echidna_delay_at_least_one_day() external view returns (bool) {
        return delay >= 1 days;
    }
}
