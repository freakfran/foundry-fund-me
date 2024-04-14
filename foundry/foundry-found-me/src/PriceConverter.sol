// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

//库：不能有任何静态变量，不能发送交易，所有函数都是internal的
library PriceConverter {
    //获取ETH->USD，调用外部合约
    //返回1ETH换n个USD，再加18个0
    //例:1ETH->3000USD
    function getVersion(
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        return priceFeed.version();
    }

    //获取ETH->USD，调用外部合约
    //返回1ETH换n个USD，再加18个0
    //例:1ETH->3000USD
    function getPrice(
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        //ABI
        //address
        //从https://docs.chain.link/data-feeds/price-feeds/addresses?network=ethereum&page=1获取
        //0x694AA1769357215DE4FAC081bf1f309aDC325306
        //例：返回3000_0000...decimals个0
        (, int256 price, , , ) = priceFeed.latestRoundData();
        uint8 decimals = priceFeed.decimals();
        //ETH/USD
        //返回的数字需要自己*1e-decimals
        //例：先减去decimals个0变成3000，再加18个0，因为在以太坊中，通常使用 18 个小数位来表示 ETH 的数量和相关的金融数据
        //最后结果3000_18个0
        return uint256(price) * 10 ** (18 - uint256(decimals));
    }

    //ethAmount 多少个ETH币
    //例：1ETH
    function getConvertRate(
        uint256 ethAmount,
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        //例：1ETH->3000USD,ethPrice为3000_18个0
        uint256 ethPrice = getPrice(priceFeed);
        //算出的数字会多18个0，将他除去
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18;
        return ethAmountInUsd;
    }

    //wei转换成USD
    function getConvertRateByWei(
        uint256 weiAmount,
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        //例：1ETH->3000USD,ethPrice为3000_18个0
        uint256 ethPrice = getPrice(priceFeed);
        //算出的数字会多18个0，将他除去
        uint256 ethAmountInUsd = (ethPrice * weiAmount) / 1e18 / 1e18;
        return ethAmountInUsd;
    }
}
