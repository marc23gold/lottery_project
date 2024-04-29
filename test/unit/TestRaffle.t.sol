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
        vm.deal(PLAYER, STARTING_BALANCE);
    }

    function testRaffleIsDoingSomething() external view {
        assert(raffle.getRaffleState() == Raffle.RaffleState.OPEN);
    }
    /**
     * @dev enter raffle tests
     */
    function testRaffleRevertsWhenYouDontPayEnough() external {
        //arrange
        vm.prank(PLAYER);
        
        //act
        vm.expectRevert(Raffle.Raffle__NotEnoughEth.selector);
        raffle.enterRaffle();

        //assert
    }

    function testRaffleRecordsPlayerWhenTheyEnter() external{
        //arrange
        vm.prank(PLAYER);

        raffle.enterRaffle{value: STARTING_BALANCE}();
        //act
        address player = raffle.getPlayer(0);
        //assert
        assert(player == PLAYER);

    }

    function testEmitsEventOnEntrance() external {
        //arrange
        vm.expectEmit(true,false,false,false, address(raffle));

        //act
        //assert
    }

}