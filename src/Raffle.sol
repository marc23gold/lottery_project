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
    error Raffle__UpKeepNotNeeded(uint256 currentBalance, uint256 playerCount, uint256 raffleState);

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
    event WinnerPicked(address indexed winner);

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

    function performUpkeep(bytes calldata /*performData*/) external {
       (bool upKeepNeeded, ) = checkUpkeep(""); 
        if(!upKeepNeeded) {
            revert Raffle__UpKeepNotNeeded(
                address(this).balance,
                s_players.length,
                uint256(s_raffleState)
            );
        }
        s_raffleState = RaffleState.CALCULATING;
        uint256 s_requestId = i_vrfCoordinator.requestRandomWords(
            i_keyHash, //gas lane
            i_subscriptionId, //address you've funded with link
            requestConfirmations,
            i_callbackGasLimit,
            numWords //number of random numbers
        );
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override{
        //Checks 
        //require (if -> errors)
        //effects (state changes    where we effect our own contract)
        //interactions with other contracts

        //checks (there are non-applicable in this case)
        //effects
        uint256 indexOfWinner = randomWords[0] % s_players.length;
        address payable winner = s_players[indexOfWinner];
        s_recentWinner = winner;
        s_raffleState = RaffleState.OPEN;

        s_players = new address payable[](0);
        s_lastTimeStamp = block.timestamp;
        emit WinnerPicked(winner);

        //interactions
        (bool success, ) = winner.call{value: address(this).balance}("");
        if(!success) {
            revert Raffle__TransactionFailed();
        }
    }

    /**
     * @dev This is the fuction the Chainlink automation nodes call
     * to see if it's time to perform an upkeep
     * The following should be true for this to return true:
     *The time interval has passed, the raffle state is open, the contract has players, and 
     The subscription is funded with link
     */

    function checkUpkeep(
        bytes memory /* checkData */
    )
        public
        view
        returns (bool upkeepNeeded, bytes memory /* performData */)
    {
        bool timeHasPassed = block.timestamp - s_lastTimeStamp >= i_interval;
        bool isOpen = RaffleState.OPEN == s_raffleState;
        bool hasBalance = address(this).balance > 0;
        bool hasPlayers = s_players.length > 0;
        upkeepNeeded = (timeHasPassed && isOpen && hasBalance && hasPlayers);
        return (upkeepNeeded, "0x0");
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
