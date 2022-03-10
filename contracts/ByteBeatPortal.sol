// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract ByteBeatPortal {
    uint256 private seed;

    uint256 totalFormulas;

    struct BbFormula {
        address sender; // The address of the user who waved.
        string formula; // The formula the user sent.
        uint256 timestamp; // The timestamp when the user waved.
    }

    BbFormula[] bbFormulas;

    mapping(address => uint256) public lastAddedFormulaAt;

    constructor() payable {
        console.log("Yo yo, I am a contract and I am smart");
        seed = (block.timestamp + block.difficulty) % 100;
    }

    event NewFormula(address indexed from, uint256 timestamp, string formula);

    function addFormula(string memory newFormula) public {
        /*
         * We need to make sure the current timestamp is at least 30-seconds bigger than the last timestamp we stored
         */
        require(
            lastAddedFormulaAt[msg.sender] + 30 seconds < block.timestamp,
            "Wait 30sc"
        );

        /*
         * Update the current timestamp we have for the user
         */
        lastAddedFormulaAt[msg.sender] = block.timestamp;

        console.log("%s has updated formula!", msg.sender);

        bbFormulas.push(BbFormula(msg.sender, newFormula, block.timestamp));
        totalFormulas += 1;

        emit NewFormula(msg.sender, block.timestamp, newFormula);

        /*
         * Generate a new seed for the next user that sends a wave
         */
        seed = (block.difficulty + block.timestamp + seed) % 100;

        console.log("Random # generated: %d", seed);

        /*
         * Give a 50% chance that the user wins the prize.
         */
        if (seed <= 50) {
            console.log("%s won!", msg.sender);

            /*
             * The same code we had before to send the prize.
             */
            uint256 prizeAmount = 0.0001 ether;
            require(
                prizeAmount <= address(this).balance,
                "Trying to withdraw more money than the contract has."
            );
            (bool success, ) = (msg.sender).call{value: prizeAmount}("");
            require(success, "Failed to withdraw money from contract.");
        }
    }

    function getFormulas() public view returns (BbFormula[] memory) {
        return bbFormulas;
    }

    function getFormulasCount() public view returns (uint256) {
        return totalFormulas;
    }
}
