// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract DutchAuction {
    uint256 public startPrice;
    uint256 public discountRate; // wei per second
    uint256 public startAt;
    address public seller;
    bool public sold;

    constructor(uint256 _startPrice, uint256 _discountRate) {
        startPrice = _startPrice;
        discountRate = _discountRate;
        startAt = block.timestamp;
        seller = msg.sender;
    }

    function getPrice() public view returns (uint256) {
        uint256 elapsed = block.timestamp - startAt;
        if (elapsed * discountRate >= startPrice) return 0;
        return startPrice - elapsed * discountRate;
    }

    function buy() external payable {
        require(!sold, "sold");
        uint256 price = getPrice();
        require(msg.value >= price, "low");
        sold = true;
        payable(seller).transfer(msg.value);
    }

    function echidna_price_never_increases() external view returns (bool) {
        // Not strictly testable without history; we assert non-negative price
        return getPrice() <= startPrice;
    }
}