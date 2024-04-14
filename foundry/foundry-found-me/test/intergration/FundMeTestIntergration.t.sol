//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;
import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FoundryMe.sol";
import {DeployFoundMe} from "../../script/DeployFoundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interaction.s.sol";

contract FoundMeTestIntergration is Test {
    FundMe fundMe;
    //自定义发送交易的人
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALABCE = 100 ether;
    uint256 constant GAS_PRICE = 1; //gas价格

    function setUp() external {
        fundMe = new DeployFoundMe().run();
        //给初始用户设置余额
        vm.deal(USER, STARTING_BALABCE);
    }

    function testUserCanFundAndOwnerWithdraw() public {
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe));

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        assert(address(fundMe).balance == 0);
    }
}
