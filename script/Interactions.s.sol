//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {VRFCoordinatorV2Mock} from "chainlink-brownie-contracts/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";

contract CreateSubscription is Script{

    function createSubscriptionUsingConfig() public returns(uint64) {
        HelperConfig config = new HelperConfig();
        (,
        ,
        address vrfCoordinator,
        ,
        ,
        
        ) = config.activeConfig();
        return createSubscription(vrfCoordinator);
    }

    function createSubscription(address vrfCoordinator) public returns(uint64){
        console.log("Creating subscription on ChainId:,", block.chainid);
        vm.startBroadcast();
        uint64 subId = VRFCoordinatorV2Mock(vrfCoordinator).createSubscription();
        vm.stopBroadcast();
        console.log("Your sub id is: ", subId);
        console.log("Please update subscription id in HelperConfig.s.sol");
        return subId;
    }

    function run() external returns(uint64) {
         return createSubscriptionUsingConfig();
    }
}

contract FundSubscription is Script{
    uint96 public constant FUND_AMOUNT = 3 ether;

    function fundSubscriptionUsingConfig() public {
        HelperConfig config = new HelperConfig();
        (,
        ,
        address vrfCoordinator,
        ,
        uint64 subscriptionId,
        ) = config.activeConfig();
        fundSubscription(vrfCoordinator, subscriptionId); 
    }

    function run() external {
        fundSubscriptionUsingConfig();
    }
}