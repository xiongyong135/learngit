// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract FundToken {
    // 通证的基础信息
    // 1.通证的名字
    // 2.通证的简称
    // 3.通证的发行数量
    // 4.owner地址
    // 5.balance address => uint256
    string public tokenName;
    string public tokenSymbol;
    uint256 public totalSupply;
    address public owner;
    mapping (address => uint) public  addressBalance;

    constructor(string memory _tokenName, string memory _tokenSymbol) {
        tokenName = _tokenName;
        tokenSymbol = _tokenSymbol;
        owner = msg.sender;
    }
    // 需要有的方法
    // mint: 获取通证
    function mint(uint256 amount) public {
        addressBalance[msg.sender] += amount;
        totalSupply += amount;
    }
    // transfer: transfer通证
    function transfer(address toAddress, uint amount) public {
        require(addressBalance[msg.sender] >= amount, "not enought money!");
        addressBalance[msg.sender] -= amount;
        addressBalance[toAddress] += amount;
    }

    // balanceOf: 查看某一个地址的通证数量
    function balanceOf(address _addr) public view returns (uint256) {
        return addressBalance[_addr];
    }




}