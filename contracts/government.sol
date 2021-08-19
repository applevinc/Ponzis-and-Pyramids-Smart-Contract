// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Governmental {
    // Global Variables
    uint32 public lastCreditorPayedOut;
    uint256 public lastTimeOfNewCredit;
    // jackpot money for last creditor
    uint256 public profitFromCrash;
    address[] public creditorAddresses;
    uint256[] public creditorAmounts;
    address public corruptElite;
    // mapping of creditor address to creditor balance
    mapping(address => uint256) buddies;
    uint256 constant TWELVE_HOURS = 43200;
    uint8 public round;

    constructor() payable {
        // The corrupt elite establishes a new government
        // this is the commitment of the corrupt Elite -
        // everything that can not be saved from a crash
        profitFromCrash = msg.value;
        corruptElite = msg.sender;
        lastTimeOfNewCredit = block.timestamp;
    }

    function lendGovernmentMoney(address buddy) public payable returns (bool) {
        uint256 amount = msg.value;

        // check if the system is already broke down.
        // If for 12h no new creditor gives new credit to the system it will brake down.
        // 12h are on average = 60*60*12/12.5 = 3456
        if (lastTimeOfNewCredit + TWELVE_HOURS < block.timestamp) {
            // Return money to sender
            payable(msg.sender).transfer(amount);

            // Sends all contract money to the last creditor
            // creditorAddresses[creditorAddresses.length - 1];

            //.transfer(profitFromCrash);
            payable(corruptElite).transfer(address(this).balance);

            // Reset contract state
            lastCreditorPayedOut = 0;
            lastTimeOfNewCredit = block.timestamp;
            profitFromCrash = 0;
            creditorAddresses = new address[](0);
            creditorAmounts = new uint256[](0);
            round += 1;
            return false;
        } else {
            // if we are still within 12h

            // the system needs to collect at least 1% of the profit
            // from a crash to stay alive
            // 10**18 = 1 ether
            if (amount >= 10**18) {
                // the System has received fresh money,
                // it will survive at least 12h more
                lastTimeOfNewCredit = block.timestamp;

                // register the new creditor and his amount with
                // 10% interest rate
                creditorAddresses.push(msg.sender);
                creditorAmounts.push((amount * 110) / 100);

                // now the money is distributed
                // first the corrupt elite grabs 5% - thieves!
                payable(corruptElite).transfer((amount * 5) / 100);

                // 5% are going into the economy (they will increase
                // the value for the person seeing the crash comming)
                if (profitFromCrash < 10000 * 10**18) {
                    profitFromCrash += (amount * 5) / 100;
                }

                // if you have a buddy in the government (and he is
                // in the creditor list) he can get 5% of your credits.
                // Make a deal with him.
                if (buddies[buddy] >= amount) {
                    payable(buddy).transfer((amount * 5) / 100);
                }
                buddies[msg.sender] += (amount * 110) / 100;

                // 90% of the money will be used to pay out old creditors
                if (
                    creditorAmounts[lastCreditorPayedOut] <=
                    address(this).balance - profitFromCrash
                ) {
                    payable(creditorAddresses[lastCreditorPayedOut]).transfer(
                        creditorAmounts[lastCreditorPayedOut]
                    );
                    buddies[
                        creditorAddresses[lastCreditorPayedOut]
                    ] -= creditorAmounts[lastCreditorPayedOut];
                    lastCreditorPayedOut += 1;
                }
                return true;
            } else {
                payable(msg.sender).transfer(amount);
                return false;
            }
        }
    }

    receive() external payable {
        lendGovernmentMoney(msg.sender);
    }

    function totalDebt() public view returns (uint256 debt) {
        for (
            uint256 i = lastCreditorPayedOut;
            i < creditorAmounts.length;
            i++
        ) {
            debt += creditorAmounts[i];
        }
    }

    function totalPayedOut() public view returns (uint256 payout) {
        for (uint256 i = 0; i < lastCreditorPayedOut; i++) {
            payout += creditorAmounts[i];
        }
    }

    // better don't do it
    // (unless you are the corrupt elite and you
    // want to establish trust in the system)
    function investInTheSystem() public payable {
        profitFromCrash += msg.value;
    }

    // From time to time the corrupt elite inherits
    // it's power to the next generation
    function inheritToNextGeneration(address nextGeneration) public {
        if (msg.sender == corruptElite) {
            corruptElite = nextGeneration;
        }
    }

    function getCreditorAddresses() public view returns (address[] memory) {
        return creditorAddresses;
    }

    function getCreditorAmounts() public view returns (uint256[] memory) {
        return creditorAmounts;
    }
}
