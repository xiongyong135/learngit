// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// FundMe
// 1.让FundMe的参与者，基于 mapping 来领取相应数量的通证
// 2.让FundMe的参与者，transfer 通证
// 3.在使用完成以后，需要 burn 通证

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {FundMe} from "./FundMe.sol";

contract FundTokenERC20 is ERC20 {

    constructor() ERC20("FundTokenERC20", "FTE") {

    }
}