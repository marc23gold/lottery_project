//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Raffle} from "../src/Raffle.sol";
import {Script} from "forge-std/Script.sol";

contract DeployRaffle is Script {
    function run() external returns(Raffle){
        Raffle raffle;
        vm.startBroadcast();
        raffle = new Raffle();
        vm.stopBroadcast();
        return raffle;
    }
}