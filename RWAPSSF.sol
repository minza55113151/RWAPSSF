// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./CommitReveal.sol";

contract RPS is CommitReveal {
    /*
    0 - Rock
    1 - Fire
    2 - Scissors
    3 - Sponge
    4 - Paper
    5 - Air
    6 - Water

    7 - Undecided
    */
    struct Player {
        uint choice;
        address addr;
        bool isCommitted;
    }
    uint private reward = 0;
    Player[2] private players;
    uint private numPlayer = 0;
    uint private numInput = 0;
    uint private numReveal = 0;

    function hashChoiceWithSalt(uint choice, string memory salt) public pure returns (bytes32) {
        require(choice >= 0 && choice <= 7);
        return keccak256(abi.encodePacked(choice, salt));
    }

    function playerJoin() public payable {
        require(numPlayer < 2);
        require(msg.value == 1 ether);
        reward += msg.value;
        players[numPlayer].addr = msg.sender;
        players[numPlayer].choice = 7;
        players[numPlayer].isCommitted = false;
        numPlayer++;
        emit PlayerJoined(msg.sender, numPlayer);
    }
    event PlayerJoined(address sender, uint numPlayer);

    function playerCommitHashChoice(bytes32 hashChoice) public  {
        // require 2 player
        require(numPlayer == 2);
        // require sender are player
        require(msg.sender == players[0].addr || msg.sender == players[1].addr);

        if (msg.sender == players[0].addr){
            require(!players[0].isCommitted, "Player already committed");
            players[0].isCommitted = true;
        }
        else if(msg.sender == players[1].addr){
            require(!players[1].isCommitted, "Player already committed");
            players[1].isCommitted = true;
        }

        commit(getHash(hashChoice));
        numInput++;
        emit PlayerCommittedHashChoice(msg.sender, numInput);
    }
    event PlayerCommittedHashChoice(address sender, uint numInput);

    function playerReveal(uint choice, string memory salt) public {
        require(numPlayer == 2);
        require(numInput == 2);
        require(msg.sender == players[0].addr || msg.sender == players[1].addr);
        require(choice >= 0 && choice <= 7);
        require(players[0].isCommitted && players[1].isCommitted);

        bytes32 hashChoice = hashChoiceWithSalt(choice, salt);
        reveal(hashChoice);
        numReveal++;
        
        if (msg.sender == players[0].addr){
            players[0].choice = choice;
        }
        else if(msg.sender == players[1].addr){
            players[1].choice = choice;
        }
        
        emit PlayerRevealed(msg.sender, numReveal);

        if (numReveal == 2) {
            _checkWinnerAndPay();
            _resetGame();
        }
    }
    event PlayerRevealed(address sender, uint numReveal);

    function _checkWinnerAndPay() private {
        uint p0Choice = players[0].choice;
        uint p1Choice = players[1].choice;
        address payable account0 = payable(players[0].addr);
        address payable account1 = payable(players[1].addr);

        if (p0Choice == p1Choice) {
            // to split reward
            account0.transfer(reward / 2);
            account1.transfer(reward / 2);
        }
        else if ((p0Choice + 1) % 7 == p1Choice || (p0Choice + 2) % 7 == p1Choice || (p0Choice + 3) % 7 == p1Choice){
            // to pay player[1]
            account0.transfer(reward);
        }
        else if ((p1Choice + 1) % 7 == p0Choice || (p1Choice + 2) % 7 == p0Choice || (p1Choice + 3) % 7 == p0Choice){
            // to pay player[0]
            account1.transfer(reward);    
        }
    }

    function _resetGame() private {
        numPlayer = 0;
        numInput = 0;
        numReveal = 0;
        reward = 0;
        emit GameReset();
    }
    event GameReset();
}
