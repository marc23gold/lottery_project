
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {VRFCoordinatorV2Mock} from "chainlink-brownie-contracts/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";
import {LinkToken} from "../test/mocks/LinkToken.sol";


contract HelperConfig is Script {

    // uint8 public constant DECIMALS = 8;
    // int256 public constant INITAL_ANSWER = 2000e8;
    ConfigType public activeConfig;
    uint256 public constant anvilKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;

    struct ConfigType{
        uint256 entranceFee;
        uint256 interval;
        address vrfCoordinator; 
        bytes32 keyHash;
        uint64 subscriptionId;
        uint32 callbackGasLimit;
        address link;
        uint256 deployerKey;
    }

    constructor() {
        if(block.chainid == 11155111){
        activeConfig = getSepoliaEthConfig();
        }
        // else if(block.chainid == 1){
        // activeConfig = getMainnetEthConfig();
        // }
        // else if(block.chainid == 111111){
        // activeConfig = getBaseSepoliaEthConfig();
        // }
        else {
        activeConfig = getOrCreateAnvilEthConfig();
    }
    } 

    function getSepoliaEthConfig() public view returns(ConfigType memory) {
        ConfigType memory sepoliaConfig = ConfigType({
        entranceFee: 0.01 ether,
        interval: 30,
        vrfCoordinator: 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625,
        keyHash: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
        subscriptionId: 0,
        callbackGasLimit: 500000,
        link: 0x779877A7B0D9E8603169DdbD7836e478b4624789,
        deployerKey: vm.envUint("PRIVATE_KEY")

        });
        return sepoliaConfig;
       
    }

    //  function getMainnetEthConfig() public pure returns(ConfigType memory) {
    //     ConfigType memory sepoliaConfig = ConfigType({priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
    //     });
    //     return sepoliaConfig;
    // }

    //  function getBaseSepoliaEthConfig() public pure returns(ConfigType memory) {
    //     ConfigType memory sepoliaConfig = ConfigType({priceFeed: 0x4aDC67696bA383F43DD60A9e78F2C97Fbbfc7cb1
    //     });
    //     return sepoliaConfig;
    // }

    function getOrCreateAnvilEthConfig() public returns(ConfigType memory) {
        if(activeConfig.vrfCoordinator != address(0)) {
            return activeConfig;
        }
        //deploy the mocks
        //return the mock address

        uint96 baseFee = 0.25 ether;
        uint96 gasPriceLink = 1e9; //1 gwei link

        vm.startBroadcast();
        VRFCoordinatorV2Mock mock = new VRFCoordinatorV2Mock(baseFee, gasPriceLink);
        LinkToken link = new LinkToken();
        vm.stopBroadcast(); 

        ConfigType memory anvilConfig = ConfigType({
        entranceFee: 0.01 ether,
        interval: 30,
        vrfCoordinator: address(mock),
        keyHash: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
        subscriptionId: 0,
        callbackGasLimit: 500000,
        link: address(link),
        deployerKey: anvilKey

        });
        return anvilConfig;
    }
}

//Deploy mocks when we're on a local anvil chain 