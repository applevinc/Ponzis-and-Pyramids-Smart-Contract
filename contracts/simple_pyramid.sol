pragma solidity ^0.8.4;

contract SimplePyramid {
    uint256 public constant MINIMUM_INVESTMENT = 1e15; // 0.001 ether
    uint256 public numInvestors = 0;
    // depth is a layer in the pyramid
    uint256 public depth = 0;
    address[] public investors;
    mapping(address => uint256) public balances;

    constructor() public payable {
        require(msg.value >= MINIMUM_INVESTMENT);
        investors.length = 3;
        investors[0] = msg.sender;
        numInvestors = 1;
        depth = 1;
        balances[address(this)] = msg.value;
    }

    fallback() external payable {
        require(msg.value >= MINIMUM_INVESTMENT);
        balances[address(this)] += msg.value;
        numInvestors += 1;
        investors[numInvestors - 1] = msg.sender;

        // If the latest investor fills a layer in the pyramid,
        // the payout logic executes
        if (numInvestors == investors.length) {
            // pay out previous layer
            uint256 endIndex = numInvestors - 2**depth;
            uint256 startIndex = endIndex - 2**(depth - 1);
            for (uint256 i = startIndex; i < endIndex; i++)
                balances[investors[i]] += MINIMUM_INVESTMENT;

            // spread remaining ether among all participants
            uint256 paid = MINIMUM_INVESTMENT * 2**(depth - 1);
            uint256 eachInvestorGets = (balances[address(this)] - paid) / numInvestors;
            for (uint256 i = 0; i < numInvestors; i++)
                balances[investors[i]] += eachInvestorGets;

            // update state variables
            balances[address(this)] = 0;
            depth += 1;
            investors.length += 2**depth;
        }
    }

    function withdraw() public {
        uint256 payout = balances[msg.sender];
        balances[msg.sender] = 0;
        msg.sender.transfer(payout);
    }
}
