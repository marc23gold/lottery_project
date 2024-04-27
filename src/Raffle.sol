//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;


/**
 * @title A sample raffle contract
 * @author mprosp
 * @notice This contract creates a sample raffle
 * @dev implements chainlink VRFv2
 */


contract Raffle {
    error Raffle__NotEnoughEth();


    uint256 private  immutable i_entranceFee;
    address payable[] private s_players;

    constructor(uint256 entranceFee) {
        i_entranceFee = entranceFee;
    }

    function enterRaffle() external payable {
        if(msg.value < i_entranceFee) {
            revert Raffle__NotEnoughEth();
        }
        s_players.push(payable(msg.sender));

    }

    function pickWinner() public {

    }


    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }

    function getPlayerCount() external view returns (uint256) {
        return s_players.length;
    }
    function getPlayers() external view returns (address[] memory) {
        return s_players;
    }
    function getPlayer(uint256 index) external view returns (address) {
        return s_players[index];
    }


}