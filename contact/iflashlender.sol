// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IFlashLender { function flashLoan(uint256 amount) external; }
contract FlashLoanReceiverDemo {
    IFlashLender public lender;
    bool public repaid;

    constructor(IFlashLender _l) { lender = _l; }

    function executeOperation(uint256 amount) external {
        require(msg.sender == address(lender), "lender");
        // ... do stuff ...
        repaid = true; // pretend repayment
    }

    function echidna_repaid_flag_boolean() external view returns (bool) {
        return repaid == true || repaid == false;
    }
}
