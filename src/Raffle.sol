//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

error Raffle__NotEnoughEth();


/**
 * @title A sample raffle contract
 * @author mprosp
 * @notice This contract creates a sample raffle
 * @dev implements chainlink VRFv2
 */


contract Raffle {

    uint256 private  immutable i_entranceFee;

    constructor(uint256 entranceFee) {
        i_entranceFee = entranceFee;
    }

    function enterRaffle() external payable {
        if(msg.value >= i_entranceFee) {
            revert Raffle__NotEnoughEth();
        }

    }

    function pickWinner() public {

    }


    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }


}