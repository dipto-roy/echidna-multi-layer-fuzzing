// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract CPAMM {
    uint112 public reserve0;
    uint112 public reserve1;

    function addLiquidity(uint112 a0, uint112 a1) external {
        reserve0 += a0;
        reserve1 += a1;
    }

    function swap0For1(uint112 dx) external {
        require(reserve0 + dx > 0 && reserve1 > 0, "empty");
        // Constant product x*y=k (approx naive, no fee)
        uint256 newX = uint256(reserve0) + dx;
        uint256 k = uint256(reserve0) * uint256(reserve1);
        uint256 newY = k / newX;
        uint112 dy = reserve1 - uint112(newY);
        reserve0 = uint112(newX);
        reserve1 = uint112(newY);
        // dy would be sent to user
    }

    function echidna_reserves_fit() external view returns (bool) {
        return reserve0 <= type(uint112).max && reserve1 <= type(uint112).max;
    }
}