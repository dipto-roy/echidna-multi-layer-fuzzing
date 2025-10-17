// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IOracle { function latest() external view returns (int256); }

contract OracleConsumer {
    IOracle public oracle;
    constructor(IOracle _o) { oracle = _o; }

    function price() external view returns (int256) { return oracle.latest(); }

    function echidna_oracle_is_set() external view returns (bool) {
        return address(oracle) != address(0);
    }
}