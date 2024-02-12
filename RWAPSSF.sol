// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract RPS {
    struct Player {
        uint choice; // 0 - Rock, 1 - Paper , 2 - Scissors, 3 - undefined
        address addr;
    }
    uint public reward = 0;
    Player[2] public players;
    uint public numPlayer = 0;
    uint public numInput = 0;

    function addPlayer() public payable {
        require(numPlayer < 2);
        require(msg.value == 1 ether);
        reward += msg.value;
        players[numPlayer].addr = msg.sender;
        players[numPlayer].choice = 3;
        numPlayer++;
    }

    function input(uint choice) public  {
        // require 2 player
        require(numPlayer == 2);
        // require sender are player
        require(msg.sender == players[0].addr || msg.sender == players[1].addr);
        // require correct choice
        require(choice == 0 || choice == 1 || choice == 2);
    
        // player choice setting
        if (msg.sender == players[0].addr){
            players[0].choice = choice;
        }
        else if(msg.sender == players[1].addr){
            players[1].choice = choice;
        }

        numInput++;
        if (numInput == 2) {
            _checkWinnerAndPay();
        }
    }

    function _checkWinnerAndPay() private {
        uint p0Choice = players[0].choice;
        uint p1Choice = players[1].choice;
        address payable account0 = payable(players[0].addr);
        address payable account1 = payable(players[1].addr);
        if ((p0Choice + 1) % 3 == p1Choice) {
            // to pay player[1]
            account1.transfer(reward);
        }
        else if ((p1Choice + 1) % 3 == p0Choice) {
            // to pay player[0]
            account0.transfer(reward);    
        }
        else {
            // to split reward
            account0.transfer(reward / 2);
            account1.transfer(reward / 2);
        }
    }
}
