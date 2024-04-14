//SPDX-License-Identifier:MIT

pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelpConfig is Script {
    //如果在本地，将在本地ganache上部署模拟合约
    //如果在测试网上，调用fork_url

    uint8 private constant DECIMALS = 8;
    int256 private constant INITIAL_PRICE = 2000e8;

    struct NetworkConfig {
        address priceFeed; //ETH/USD priceFeed address
    }

    NetworkConfig public activeNetworkConfig;

    constructor() {
        //sepolia的chainid是11155111
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else {
            activeNetworkConfig = getOrCreateGanacheEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        //priceFeed address
        NetworkConfig memory networkConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return networkConfig;
    }

    function getOrCreateGanacheEthConfig()
        public
        returns (NetworkConfig memory)
    {
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }
        //priceFeed address
        //部署一个模拟的合约
        vm.startBroadcast();
        MockV3Aggregator mockV3Aggregator = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        );
        vm.stopBroadcast();
        //返回模拟合约地址
        NetworkConfig memory networkConfig = NetworkConfig({
            priceFeed: address(mockV3Aggregator)
        });
        return networkConfig;
    }
}
