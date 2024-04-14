//SPDX-License-Identifier:MIT

pragma solidity ^0.8.0;
import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FoundryMe.sol";
import {HelpConfig} from "./HelpConfig.s.sol";

contract DeployFoundMe is Script {
    function run() external returns (FundMe) {
        HelpConfig helpConfig = new HelpConfig();
        //只有foundry才能用VM
        //startBroadcast之后的代码都将发送到RPC
        vm.startBroadcast();
        FundMe fundMe = new FundMe(helpConfig.activeNetworkConfig());
        vm.stopBroadcast();
        return fundMe;
    }
}
