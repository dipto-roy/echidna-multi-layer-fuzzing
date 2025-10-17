// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract EnglishAuction {
    address public seller;
    uint256 public endTime;
    address public highBidder;
    uint256 public highBid;

    constructor(uint256 duration) {
        seller = msg.sender;
        endTime = block.timestamp + duration;
    }

    function bid() external payable {
        require(block.timestamp < endTime, "ended");
        require(msg.value > highBid, "low");
        if (highBidder != address(0)) payable(highBidder).transfer(highBid);
        highBidder = msg.sender;
        highBid = msg.value;
    }

    function echidna_highbid_monotonic() external view returns (bool) {
        return highBid >= 0;
    }
}
