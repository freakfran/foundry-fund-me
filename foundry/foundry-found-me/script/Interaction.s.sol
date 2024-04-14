//SPDX-License-Identifier:MIT

pragma solidity ^0.8.0;
import {Script, console} from "forge-std/Script.sol";
import {FundMe} from "../src/FoundryMe.sol";
import {HelpConfig} from "./HelpConfig.s.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";

//存钱脚本
contract FundFundMe is Script {
    uint256 constant SEND_VALUE = 0.1 ether;
    address USER = makeAddr("user");
    uint256 constant STARTING_BALABCE = 100 ether;
    uint256 constant GAS_PRICE = 1; //gas价格

    function fundFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).fund{value: SEND_VALUE}();
        vm.stopBroadcast();
        console.log("Funded FundMe with %s", SEND_VALUE);
    }

    function run() external {
        address recentDeployAddress = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        vm.startBroadcast();
        fundFundMe(recentDeployAddress);
        vm.stopBroadcast();
    }
}

//提款脚本
contract WithdrawFundMe is Script {
    function withdrawFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).withdraw();
        vm.stopBroadcast();
        console.log("Withdraw FundMe balance!");
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        withdrawFundMe(mostRecentlyDeployed);
    }
}
