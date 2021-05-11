// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract GradualPonzi {
    address[] public investors;
    mapping(address => uint256) public balances;
    uint256 public constant MINIMUM_INVESTMENT = 1e15;

    constructor() {
        investors.push(msg.sender);
    }

    fallback() external payable {
        require(msg.value >= MINIMUM_INVESTMENT);

        uint256 eachInvestorGets = msg.value / investors.length;

        for (uint256 i = 0; i < investors.length; i++) {
            balances[investors[i]] += eachInvestorGets;
        }
        
        investors.push(msg.sender);
    }

    receive() external payable {}

    function withdraw() public {
        uint256 payout = balances[msg.sender];
        balances[msg.sender] = 0;
        payable(msg.sender).transfer(payout);
    }
}
