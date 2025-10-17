// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract RefundableCrowdsale {
    uint256 public goal = 10 ether;
    uint256 public raised;
    bool public refunded;

    function contribute() external payable {
        raised += msg.value;
    }

    function refund() external {
        require(raised < goal, "met");
        refunded = true;
        // skip actual refunds for demo
    }

    function echidna_goal_nonzero() external view returns (bool) {
        return goal > 0;
    }
}


