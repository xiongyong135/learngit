// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";


contract FundMe{
    mapping (address => uint) public funderToAmount;
    // uint MIN_AMOUNT = 1 * 10 ** 18;  // 1个eth = 10 ** 18 wei
    uint MIN_AMOUNT = 1 * 10 ** 18;  // 1 USD
    AggregatorV3Interface internal priceFeed;

    uint TARGET_AMOUNT = 10 * 10 ** 18;  // 10 USD

    address public  owner;

    constructor () {
        // sepolia testnet
        priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        owner = msg.sender;
    }

    function fund() external payable {
        uint amount = msg.value;
        uint usdAmount = convertEth2USD(amount);
        require(usdAmount >= MIN_AMOUNT, "USD Amount too low!");
        // require(amount >= MIN_AMOUNT, "Amount too low!");

        funderToAmount[msg.sender] += msg.value;
    }

    /**
    * Returns the latest answer.
    */
    function getChainlinkDataFeedLatestAnswer() public view returns (int) {
        // prettier-ignore
        (
        /* uint80 roundId */
        ,
        int answer,
        /*uint256 startedAt*/
        ,
        /*uint256 updatedAt*/
        ,
        /*uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();
        return answer;
    }

    function convertEth2USD (uint256 ethAmount) internal view returns ( uint256) {
        uint256 price = uint256(getChainlinkDataFeedLatestAnswer());
        // 1 eth = 10^18  price = 10^8 usd
        // ethAmount * price / 10^18 * 10^8
        // 入参 1个eth 1 * 10 ** 18
        // price 是3000 USD 3000 * 10 ** 8
        // 希望返回 1 * 10 ** 18 * 3000
        // 1 * 10 ** 18 *  (3000 * 10 ** 8) / (10 ** 8) = 1 * 10 ** 18 * 3000 表示 1个eth 等于 3000 u
        // 
        return ethAmount * price / (10 ** 8);
    }

    // 提款，金额满足，owner可以提款将合约余额转到用户余额
    function getFund() external {
        uint contractBalance = address(this).balance;
        address sender = msg.sender;
        require(convertEth2USD(contractBalance) >= TARGET_AMOUNT, "Not Reach Target Amount!");
        require(owner == sender, "you are not the owner!");
        // transfer
        // payable (sender).transfer(contractBalance);
        // send
        // bool success = payable (sender).send(contractBalance);
        // require(success, "Failed!");890
        // call
        bool success;
        (success, ) = payable (sender).call{value: contractBalance}("");
        require(success, "Failed!");

    }

    // 退款，如果目标未达成，则投资用户可以提走自己的投资金额
    function refund() external {
        address myAddress = msg.sender;
        uint contractBalance = address(this).balance;
        require(contractBalance < TARGET_AMOUNT, "Target is reached!");
        uint myContractAmount = funderToAmount[myAddress];
        require(myContractAmount > 0, "you have no balance in this contract!");
        bool success;
        (success, ) = payable (myAddress).call{value: myContractAmount}("");
        require(success, "Failed!");
    }

}