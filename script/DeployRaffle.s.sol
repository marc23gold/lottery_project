//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Raffle} from "../src/Raffle.sol";
import {Script} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployRaffle is Script {
    function run() external returns(Raffle, HelperConfig){
        HelperConfig config = new HelperConfig();
        
        
        
        (uint256 entranceFee,
        uint256 interval,
        address vrfCoordinator,
        bytes32 keyHash,
        uint64 subscriptionId,
        uint32 callbackGasLimit
        ) = config.activeConfig();
        Raffle raffle;
        vm.startBroadcast();
        raffle = new Raffle(
        entranceFee,
        interval,
        vrfCoordinator,
        keyHash,
        subscriptionId,
        callbackGasLimit
        );
        vm.stopBroadcast();
        return (raffle, config);
    }
}