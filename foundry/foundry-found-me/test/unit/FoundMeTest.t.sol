//SPDX-License-Identifier:MIT

pragma solidity ^0.8.0;
import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FoundryMe.sol";
import {DeployFoundMe} from "../../script/DeployFoundMe.s.sol";

contract FoundMeTest is Test {
    FundMe fundMe;

    //自定义发送交易的人
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALABCE = 100 ether;
    uint256 constant GAS_PRICE = 1; //gas价格

    //部署合约，所有测试文件的第一步
    //forge test最先执行setup
    function setUp() external {
        fundMe = new DeployFoundMe().run();
        //给初始用户设置余额
        vm.deal(USER, STARTING_BALABCE);
    }

    function testMinmunUSDIsFifty() public {
        //forge test -vv可以看到日志
        console.log("foundMe.MINIMUM_USD:", fundMe.MINIMUM_USD());
        assertEq(fundMe.MINIMUM_USD(), 50);
    }

    function testMsgSendIsOwner() public {
        console.log("owner:", fundMe.i_owner());
        //这样是会测试不通过，fundMe.i_owner()是调用setUp()部署合约的，msg.sender是调用testMsgSendIsOwner()的
        assertEq(fundMe.i_owner(), msg.sender);
        //assertEq(fundMe.i_owner(), address(this));
    }

    function testPriceVersionAccurate() public {
        uint256 version = fundMe.getVersion();
        console.log("version:", version);
        assertEq(version, 4);
    }

    function testFundFailsWitoutEnoughEth() public {
        //应该要触发revert，如果没有，测试不通过
        vm.expectRevert();
        fundMe.fund();
    }

    modifier funded() {
        //设置下个交易由USER发送
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testFundSuccessUpdataStructure() public funded {
        //uint256 amount = fundMe.getAddressToAmountFunded(msg.sender);
        uint256 amount = fundMe.getAddressToAmountFunded(USER);
        assertEq(amount, SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public funded {
        address user = fundMe.getFunder(0);
        assertEq(user, USER);
    }

    function testOnlyOwenerCanWithdraw() public funded {
        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }

    function testWithdrawSuccess() public funded {
        //arrange
        uint256 startingBalance = fundMe.getOwner().balance;
        //act
        //uint256 gasStart = gasleft(); //gasleft:solidity内置函数，剩余gas值
        //vm.txGasPrice(GAS_PRICE); //设置交易的gas价格
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        uint256 endBalance = fundMe.getOwner().balance;
        uint256 endTotalBalance = address(fundMe).balance;
        //uint256 gasEnd = gasleft();
        //uint256 spendtGasPrice = (gasStart - gasEnd) * tx.gasprice;
        // console.log("gasStart:", gasStart);
        // console.log("gasPrice:", tx.gasprice);
        // console.log("gasEnd:", gasEnd);
        // console.log("spendtGasPrice:", spendtGasPrice);
        //assert
        assertEq(startingBalance + SEND_VALUE, endBalance);
        assertEq(endTotalBalance, 0);
    }

    function testWithdrawFromMutipleFunders() public funded {
        //uint160才能转为地址
        uint160 numberOfFunders = 10;
        //尽量不用address(0)
        uint160 startingIndex = 1;

        for (uint160 i = startingIndex; i < numberOfFunders; i++) {
            hoax(address(i), SEND_VALUE); //hoax:给地址设置余额并且自动prank
            fundMe.fund{value: SEND_VALUE}();
        }
        uint256 startingBalance = fundMe.getOwner().balance;
        uint256 startingTotalBalance = address(fundMe).balance;
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        uint256 endBalance = fundMe.getOwner().balance;
        uint256 endTotalBalance = address(fundMe).balance;
        //assert
        assertEq(startingBalance + startingTotalBalance, endBalance);
        assertEq(endTotalBalance, 0);
    }

    function testOnlyOwenerCanWithdrawCheaper() public funded {
        vm.expectRevert();
        vm.prank(USER);
        fundMe.cheaperWithdraw();
    }

    function testWithdrawSuccessCheaper() public funded {
        //arrange
        uint256 startingBalance = fundMe.getOwner().balance;
        //act
        //uint256 gasStart = gasleft(); //gasleft:solidity内置函数，剩余gas值
        //vm.txGasPrice(GAS_PRICE); //设置交易的gas价格
        vm.prank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        uint256 endBalance = fundMe.getOwner().balance;
        uint256 endTotalBalance = address(fundMe).balance;
        //uint256 gasEnd = gasleft();
        //uint256 spendtGasPrice = (gasStart - gasEnd) * tx.gasprice;
        // console.log("gasStart:", gasStart);
        // console.log("gasPrice:", tx.gasprice);
        // console.log("gasEnd:", gasEnd);
        // console.log("spendtGasPrice:", spendtGasPrice);
        //assert
        assertEq(startingBalance + SEND_VALUE, endBalance);
        assertEq(endTotalBalance, 0);
    }

    function testWithdrawFromMutipleFundersCheaper() public funded {
        //uint160才能转为地址
        uint160 numberOfFunders = 10;
        //尽量不用address(0)
        uint160 startingIndex = 1;

        for (uint160 i = startingIndex; i < numberOfFunders; i++) {
            hoax(address(i), SEND_VALUE); //hoax:给地址设置余额并且自动prank
            fundMe.fund{value: SEND_VALUE}();
        }
        uint256 startingBalance = fundMe.getOwner().balance;
        uint256 startingTotalBalance = address(fundMe).balance;
        vm.prank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        uint256 endBalance = fundMe.getOwner().balance;
        uint256 endTotalBalance = address(fundMe).balance;
        //assert
        assertEq(startingBalance + startingTotalBalance, endBalance);
        assertEq(endTotalBalance, 0);
    }
}
