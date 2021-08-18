// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/*
The simplest version of a Ponzi involves taking the money sent by the 
current investor and transfering it to the previous investor. As long as 
each investment is larger than the previous one, every investor except the 
last will get a return on their investment.
*/

contract SimplePonzi {
    address public currentInvestor;
    uint256 public currentInvestment = 0;

    receive() external payable {
        // new investments must be 10% greater than current investment
        uint256 minimumInvestment = (currentInvestment * 11) / 10;
        require(msg.value > minimumInvestment);

        // document new investor
        address payable previousInvestor = payable(currentInvestor);
        currentInvestor = msg.sender;
        currentInvestment = msg.value;

        // payout previous investor
        previousInvestor.transfer(msg.value);
    }
}
