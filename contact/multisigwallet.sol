// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MultiSigWallet {
    address[] public owners;
    mapping(address => bool) public isOwner;
    uint256 public threshold;

    struct Tx { address to; uint256 value; bytes data; uint256 approvals; bool executed; }
    Tx[] public txs;
    mapping(uint256 => mapping(address => bool)) public approved;

    constructor(address[] memory _owners, uint256 _threshold) {
        require(_owners.length >= _threshold && _threshold > 0, "bad");
        for (uint i=0;i<_owners.length;i++) {
            require(!isOwner[_owners[i]] && _owners[i] != address(0), "dup");
            isOwner[_owners[i]] = true;
        }
        owners = _owners;
        threshold = _threshold;
    }

    receive() external payable {}

    function submit(address to, uint256 value, bytes calldata data) external returns(uint256 id) {
        require(isOwner[msg.sender], "owner");
        txs.push(Tx(to,value,data,0,false));
        id = txs.length-1;
    }

    function approveTx(uint256 id) external {
        require(isOwner[msg.sender], "owner");
        require(!approved[id][msg.sender], "dup");
        approved[id][msg.sender] = true;
        txs[id].approvals += 1;
    }

    function execute(uint256 id) external {
        Tx storage t = txs[id];
        require(!t.executed, "done");
        require(t.approvals >= threshold, "low");
        t.executed = true;
        (bool ok,) = t.to.call{value:t.value}(t.data);
        require(ok, "call fail");
    }

    function echidna_threshold_nonzero() external view returns (bool) {
        return threshold > 0;
    }
}