//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";


/**
 * @title A sample raffle contract
 * @author mprosp
 * @notice This contract creates a sample raffle
 * @dev implements chainlink VRFv2
 */


contract Raffle is VRFConsumerBaseV2 {
    error Raffle__NotEnoughEth();
    error Raffle__TransactionFailed();
    error Raffle__RaffleNotOpen(); 

    enum RaffleState {
        OPEN,
        CALCULATING
    }


    uint16 private constant requestConfirmations = 3;
    uint32 private constant numWords = 1;
    uint32 private immutable i_callbackGasLimit;
    uint256 private  immutable i_entranceFee;
    address payable[] private s_players;
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    bytes32 private immutable i_keyHash;
    uint64 private immutable i_subscriptionId;
    address private s_recentWinner;
    RaffleState private s_raffleState;

    //@dev duration of the lottery in seconds
    uint256 private immutable i_interval;
    uint256 private s_lastTimeStamp;

    event EnteredRaffle(address indexed player);

    constructor(uint256 entranceFee, uint256 interval, address vrfCoordinator, bytes32 keyHash, uint64 subscriptionId,
    uint32 callbackGasLimit) VRFConsumerBaseV2(vrfCoordinator){
        i_entranceFee = entranceFee;
        i_interval = interval;
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinator);
        i_keyHash = keyHash;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
        s_raffleState = RaffleState.OPEN;
    }

    function enterRaffle() external payable {
        if(msg.value < i_entranceFee) {
            revert Raffle__NotEnoughEth();
        }
        if(s_raffleState != RaffleState.OPEN) {
            revert();
        }
        s_players.push(payable(msg.sender));
        emit EnteredRaffle(msg.sender);
    }

    function pickWinner() external {
        if(block.timestamp - s_lastTimeStamp <= i_interval) {
            revert Raffle__RaffleNotOpen();
        }
        uint256 s_requestId = i_vrfCoordinator.requestRandomWords(
            i_keyHash, //gas lane
            i_subscriptionId, //address you've funded with link
            requestConfirmations,
            i_callbackGasLimit,
            numWords //number of random numbers
        );
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override{
        uint256 indexOfWinner = randomWords[0] % s_players.length;
        address payable winner = s_players[indexOfWinner];
        s_recentWinner = winner;
        (bool success, ) = s_recentWinner.call{value: address(this).balance}("");
        if(!success) {
            revert Raffle__TransactionFailed();
        }
    }


    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }

    function getPlayerCount() external view returns (uint256) {
        return s_players.length;
    }
    function getPlayer(uint256 index) external view returns (address) {
        return s_players[index];
    }


}