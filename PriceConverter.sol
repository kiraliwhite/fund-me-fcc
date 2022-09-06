// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// interface 貼在這裡
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    //新的function 呼叫interface內的ABI
    function getVersion() internal view returns (uint) {
      //AggregatorV3Interface interface1 = AggregatorV3Interface(0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e);
      //return interface1.version();
      //合約地址是Goerli 測試網
      return AggregatorV3Interface(0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e).version();
    }

    function getPrice() internal view returns (uint256) {
      AggregatorV3Interface priceFeed = AggregatorV3Interface(0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e);
      (,int256 ethPrice,,,) = priceFeed.latestRoundData();
      return uint256(ethPrice * 1e10);
    }

    //                                以太幣個數
    function getConversionRate(uint256 _ethAmount) internal view returns(uint256) {
      uint256 ethPrice = getPrice();
      //會需要除以1e18 是因為_ethAmount 與 ethPrice的單位都是1e18 兩者相乘會得到1e36, 代表36個0,所以要把18個0拿掉
      uint256 totalUSD = (_ethAmount * ethPrice) / 1e18;
      return totalUSD;
    }
}
