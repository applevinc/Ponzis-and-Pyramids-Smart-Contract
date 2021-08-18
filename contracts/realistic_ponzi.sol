// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/*
each time an new investor invest, old investors receives
a share of the investment
*/

contract GradualPonzi {
    address[] public investors;
    mapping(address => uint256) public balances;
    // MINIMUM_INVESTMENT = 10^15 wei
    uint256 public constant MINIMUM_INVESTMENT = 1e15;

    constructor() {
        investors.push(msg.sender);
    }

    receive() external payable {
        require(
            msg.value >= MINIMUM_INVESTMENT,
            "amount is less than MINIMUM_INVESTMENT"
        );

        uint256 eachInvestorGets = msg.value / investors.length;

        // update investors balances
        for (uint256 i = 0; i < investors.length; i++) {
            balances[investors[i]] += eachInvestorGets;
        }

        investors.push(msg.sender);
    }

    function withdraw() public {
        uint256 payout = balances[msg.sender];
        balances[msg.sender] = 0;
        payable(msg.sender).transfer(payout);
    }
}
