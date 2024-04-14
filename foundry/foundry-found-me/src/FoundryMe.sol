//提取众筹

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;
import "./PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
//在合约外自定义错误
error FoundMe_NotOwner();

contract FundMe {
    //让uint256能调用PriceConverter中的方法
    using PriceConverter for uint256;
    uint256 public constant MINIMUM_USD = 50;
    //记录众筹者的地址
    address[] private s_funders;
    //记录每个众筹者众筹了多少钱
    mapping(address => uint256) private s_addressToFundAmout;

    //发布者的地址
    address public immutable i_owner;
    AggregatorV3Interface priceFeed_s;

    //构造器，部署合约后立即执行一次
    constructor(address fundPriceFeed) {
        i_owner = msg.sender;
        priceFeed_s = AggregatorV3Interface(fundPriceFeed);
    }

    //从用户获得众筹
    //payable可以支付
    function fund() public payable {
        //以美元为单位设置最小众筹
        //require至少支付1ETH:1的18次方wei,第二个参数为错误信息
        //会自动把msg.value传给getConvertRateByWei的第一个参数，如果有其他参数，需要在括号中写明
        require(
            msg.value.getConvertRateByWei(priceFeed_s) >= MINIMUM_USD,
            "Didn't send enough"
        );
        s_addressToFundAmout[msg.sender] = msg.value;
        s_funders.push(msg.sender);
    }

    //取钱
    function withdraw() public onlyOwner {
        //用for循环重置addressToFundAmout
        for (
            uint256 funderIndex = 0;
            funderIndex < s_funders.length;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToFundAmout[funder] = 0;
        }
        //重置数组
        s_funders = new address[](0);
        //获取资金的三种方法
        //send,transfer,call
        //1.transfer,payable address才能转账
        //2300gas,如果失败，会抛错误并回滚交易
        //payable(msg.sender).transfer(address(this).balance);
        //2.send
        //2300gas,如果失败，会返回一个bool值代表是否成功，不会回滚交易
        //bool sendOk = payable(msg.sender).send(address(this).balance);
        //手动回滚
        //require(sendOk,"send failed");
        //3.call,返回一个bool值和一个bytes的值，代表是否调用成功和返回值
        (bool callOk, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callOk, "call failed");
    }

    //取钱
    function cheaperWithdraw() public onlyOwner {
        uint256 length = s_funders.length;
        //用for循环重置addressToFundAmout
        for (uint256 funderIndex = 0; funderIndex < length; funderIndex++) {
            address funder = s_funders[funderIndex];
            s_addressToFundAmout[funder] = 0;
        }
        //重置数组
        s_funders = new address[](0);
        //获取资金的三种方法
        //send,transfer,call
        //1.transfer,payable address才能转账
        //2300gas,如果失败，会抛错误并回滚交易
        //payable(msg.sender).transfer(address(this).balance);
        //2.send
        //2300gas,如果失败，会返回一个bool值代表是否成功，不会回滚交易
        //bool sendOk = payable(msg.sender).send(address(this).balance);
        //手动回滚
        //require(sendOk,"send failed");
        //3.call,返回一个bool值和一个bytes的值，代表是否调用成功和返回值
        (bool callOk, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callOk, "call failed");
    }

    //modifier_以上的被拼接到代码中
    modifier onlyOwner() {
        //require(msg.sender == i_owner, "You are not the owner");
        //使用自定义错误而不是require
        if (msg.sender != i_owner) {
            revert FoundMe_NotOwner();
        }
        //需要一个下划线，代表余下的代码
        _;
    }

    //如果有人在不调用fund方法的情况下给合约转账，我们就无法记录到信息
    //这种情况下，会调用receive
    receive() external payable {
        fund();
    }

    //如果外部调用一个合约内没有的函数，会调用fallback
    fallback() external payable {
        fund();
    }

    /** Getter Functions */

    /**
     * @notice Gets the amount that an address has funded
     *  @param fundingAddress the address of the funder
     *  @return the amount funded
     */
    function getAddressToAmountFunded(
        address fundingAddress
    ) public view returns (uint256) {
        return s_addressToFundAmout[fundingAddress];
    }

    function getVersion() public view returns (uint256) {
        return priceFeed_s.version();
    }

    function getFunder(uint256 index) public view returns (address) {
        return s_funders[index];
    }

    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return priceFeed_s;
    }
}
