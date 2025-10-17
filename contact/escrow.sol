// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Escrow {
    address public payer;
    address public payee;
    bool public funded;
    bool public released;

    function fund(address _payee) external payable {
        require(!funded, "funded");
        payer = msg.sender;
        payee = _payee;
        funded = true;
    }

    function release() external {
        require(funded && !released, "state");
        released = true;
        payable(payee).transfer(address(this).balance);
    }

    function echidna_single_release() external view returns (bool) {
        return !(released && !funded);
    }
}
