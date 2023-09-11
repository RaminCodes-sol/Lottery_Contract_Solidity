// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;




contract Lottery_Contract {
    address public owner;
    address payable [] public players;
    uint public lotteryId;

    mapping (uint => address payable) public lotteryWinnersHistory;



    constructor () {
        owner = msg.sender;
        lotteryId = 1;
    }
    
    modifier OnlyOwner () {
        require(msg.sender == owner, "Only the owner can call this function!");
        _;
    }


    /*-------Events-------*/
    event PlayerEntered(address indexed, uint time);
    event WinnerPicked(address indexed);


    /*-------Get-Balance-------*/
    function getBalance () public view returns(uint) {
        return address(this).balance;
    }


    /*-------Enter-Lottery-------*/
    function enterLottery () public payable {
        require(msg.sender != address(0), "Invalid sender address!");
        require(msg.value >= 0.1 ether, "Insufficient value.");
        
        players.push(payable(msg.sender));

        emit PlayerEntered(msg.sender, block.timestamp);
    }


    /*-------Get-Players-------*/
    function getPlayers () public view returns(address payable[] memory) {
        return players;
    }


    /*-------Get-Random-Number-------*/
    function getRandomNumber () private view returns (uint) {
        return uint(keccak256(abi.encodePacked(owner, block.timestamp, block.number)));
    }


    /*-------Pick-Winner-------*/
    function pickWinner () public payable OnlyOwner {
        require(players.length > 0, "No player has participated.");

        uint index = getRandomNumber() % players.length;

        (bool success, ) = players[index].call{value: address(this).balance}("");
        require(success, "Transferring Failed.");
        

        lotteryWinnersHistory[lotteryId] = players[index];
        lotteryId += 1;

        //reset the players
        players = new address payable[](0);
    }

    
    /*-------Get-Lottery-Winner--------*/
    function getLotteryWinner (uint _lotteryId) public view returns(address payable) {
        return lotteryWinnersHistory[_lotteryId];
    }
    
}
