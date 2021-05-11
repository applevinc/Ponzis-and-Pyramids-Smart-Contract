// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract SimplePonzi {
    address public currentInvestor;
    uint256 public currentInvestment = 0;

    fallback() external payable {
        // new investments must be 10% greater than current investment
        uint256 minimumInvestment = (currentInvestment * 1) / 10;
        require(msg.value > minimumInvestment);

        // document new investor
        address payable previousInvestor = payable(currentInvestor);
        currentInvestor = msg.sender;
        currentInvestment = msg.value;

        // payout previous investor
        previousInvestor.transfer(msg.value);
    }

    receive() external payable {}

}
