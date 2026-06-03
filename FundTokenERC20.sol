// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// FundMe
// 1.让FundMe的参与者，基于 mapping 来领取相应数量的通证
// 2.让FundMe的参与者，transfer 通证
// 3.在使用完成以后，需要 burn 通证

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {FundMe} from "./FundMe.sol";

contract FundTokenERC20 is ERC20 {

    FundMe fundMe;

    constructor(address fundMeContractAddr) ERC20("FundTokenERC20", "FTE") {
        fundMe = FundMe(fundMeContractAddr);
    }

    function mint(uint amount) public getFundSuccess{
        // 每个用户都可以调用，会做权限校验：拥有fundMe的用户可以铸币发放
        // require(fundMe.funderAmount(msg.sender) > amount, "you have no amount in fundMe!");
        require(fundMe.funderToAmount(msg.sender) >= amount, "you have no amount in fundMe!");

        // 发放token
        _mint(msg.sender, amount);
        // fundMe 数量同步减少
        fundMe.setfunderAmount(msg.sender, fundMe.funderAmount(msg.sender) - amount);

    }

    // 将erc20 token 兑换 领奖
    function claim(uint amount) public getFundSuccess{
        require(balanceOf(msg.sender) >= amount, "you have not enough balance");
        /** 做一些奖励逻辑处理 **/
        _burn(msg.sender, amount);
    }

    modifier getFundSuccess() {
        require(fundMe.getFundSuccess(), "you must wait the fundMe end!");
        _;
    }

}