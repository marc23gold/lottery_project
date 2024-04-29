//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {DeployRaffle} from "../../script/DeployRaffle.s.sol";
import {Test, console} from "forge-std/Test.sol";
import {Raffle} from "../../src/Raffle.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

contract TestRaffle is Test {
    Raffle raffle;
    HelperConfig config;

    address public PLAYER = makeAddr("player");
    uint256 public constant STARTING_BALANCE = 10 ether; 
    uint256 entranceFee;
    uint256 interval;
    address vrfCoordinator;
    bytes32 keyHash;
    uint64 subscriptionId;
    uint32 callbackGasLimit;
        

    function setUp() external {
        DeployRaffle deployRaffle = new DeployRaffle();
        (raffle, config) = deployRaffle.run();
         ( entranceFee,
         interval,
         vrfCoordinator,
        keyHash,
        subscriptionId,
        callbackGasLimit
        ) = config.activeConfig();
        console.log("Raffle address: ", address(raffle));
    }
}