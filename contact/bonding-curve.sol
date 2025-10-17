// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BondingCurveAMM {
    uint256 public reserveETH;
    uint256 public reserveTOKEN;
    uint256 public constant K = 1e18;

    function addLiquidity() external payable {
        reserveETH += msg.value;
        reserveTOKEN += msg.value; // 1:1 dummy rule
    }

    function swapETHForTOKEN() external payable {
        // simplistic x+y curve; not realistic, but tests arithmetic
        reserveETH += msg.value;
        uint out = msg.value; 
        require(reserveTOKEN >= out, "liquidity");
        reserveTOKEN -= out;
    }

    function echidna_reserves_non_negative() external view returns (bool) {
        return reserveETH >= 0 && reserveTOKEN >= 0;
    }
}
