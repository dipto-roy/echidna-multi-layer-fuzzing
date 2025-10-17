// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract PaymentSplitterDemo {
    address[] public payees;
    uint256[] public shares;
    mapping(address => uint256) public released;

    constructor(address[] memory p, uint256[] memory s) {
        require(p.length == s.length && p.length > 0, "bad");
        payees = p; shares = s;
    }

    receive() external payable {}

    function totalShares() public view returns (uint256 t) {
        for (uint i=0;i<shares.length;i++) t += shares[i];
    }

    function release(address to) external {
        uint256 t = totalShares();
        uint256 due = (address(this).balance * shareOf(to)) / t;
        released[to] += due;
        payable(to).transfer(due);
    }

    function shareOf(address to) public view returns (uint256) {
        for (uint i=0;i<payees.length;i++) if (payees[i] == to) return shares[i];
        return 0;
    }

    function echidna_totalShares_positive() external view returns (bool) {
        return totalShares() > 0;
    }
}
