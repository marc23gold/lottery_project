//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {DeployRaffle} from "../../script/DeployRaffle.s.sol";
import {Test, console} from "forge-std/Test.sol";
import {Raffle} from "../../src/Raffle.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {Vm} from "forge-std/Vm.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";

contract TestRaffle is Test {
    Raffle raffle;
    HelperConfig config;

    /*events*/
    event EnteredRaffle(address indexed player);

    address public PLAYER = makeAddr("player");
    uint256 public constant STARTING_BALANCE = 10 ether; 
    uint256 entranceFee;
    uint256 interval;
    address vrfCoordinator;
    bytes32 keyHash;
    uint64 subscriptionId;
    uint32 callbackGasLimit;
    address link;
        

    function setUp() external {
        DeployRaffle deployRaffle = new DeployRaffle();
        (raffle, config) = deployRaffle.run();
         ( entranceFee,
         interval,
         vrfCoordinator,
        keyHash,
        subscriptionId,
        callbackGasLimit,
        link
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
        vm.prank(PLAYER);
        vm.expectEmit(true,false,false,false, address(raffle));
        emit EnteredRaffle(PLAYER);
        raffle.enterRaffle{value: entranceFee}();

        //act
        //assert
    }

    function testCantEnterWhenRaffleIsCalculating() external {
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        raffle.performUpkeep("");
        vm.expectRevert(Raffle.Raffle__RaffleNotOpen.selector);
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
    }

    //check up keep tests
    function testCheckUpKeepTurnsFalseIfItHasNoBalance() external {
        //Arrange
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);

        //Act
        (bool upkeepNeeded,) = raffle.checkUpkeep("");

        //Assert
        assert(!upkeepNeeded);
    }

    function testCheckUpKeepReturnsFalseIfRaffleNotOpen() external {
        //arrange
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        raffle.performUpkeep("");

        //act 
        (bool upkeepNeeded,) = raffle.checkUpkeep(""); 

        //assert
        assert(upkeepNeeded == false);
    }

    function testUpKeepCanOnlyRunIfCheckUpKeepIsTrue() public {
        //arrange
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);

        //act / assert
        raffle.performUpkeep("");
    }

    function testPerfromUpkeepIfCheckUpkeepIsFalse() public {
        //arrange
        uint256 currentBalance = 0;
        uint256 numPlayers = 0; 
        uint256 raffleState = 0; 
        //act/assert 
        vm.expectRevert(abi.encodeWithSelector(Raffle.Raffle__NotEnoughEth.selector, currentBalance, numPlayers, raffleState));
        raffle.performUpkeep("");

        
    }

    modifier arrangeTest()  {
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        _;
    }
        //What if I need to test using the output of an event? 
    function testPerformUpKeepStateandEvent() public  arrangeTest{
        //arrange 

        //act 
        vm.recordLogs();
        raffle.performUpkeep("");
        Vm.Log[] memory entries = vm.getRecordedLogs();
        bytes32 requestId = entries[1].topics[1];

        Raffle.RaffleState rState = raffle.getRaffleState();

        //assert 
        assert(uint256(requestId) > 0);
        assert(uint256(rState) == 1);
    }

    function testFulfilRandomWordsCanOnlyBeCalledAfterPerformUpKeep() public arrangeTest {
        //arrange 
        vm.expectRevert("nonexistent request");
        VRFCoordinatorV2Mock(vrfCoordinator).fulfillRandomWords(0, address(raffle));
    }
}