// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "./PriceConverter.sol";

error youNotOwner123();
error failed();

contract FundMe {
    using PriceConverter for uint256;

    address public immutable i_owner;

    constructor() {
      i_owner = msg.sender;
    }

    address[] public funders;
    mapping(address => uint) public addressToAmountFunded;
    
    uint public constant MINIUSD = 10 * 1e18; //因為最小單位是wei

    function fund() public payable {
        require(msg.value.getConversionRate() > MINIUSD,"The amount you sent is too low");
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner {
      //使用for迴圈 清除addressToAmountFunded 的mapping 也就是陣列中的每一個地址捐獻多少錢 把它歸0
      for(uint i=0; i < funders.length; i++){
        address tempFund = funders[i];
        addressToAmountFunded[tempFund] = 0;
      }
      //直接把funders陣列 也就是捐款人名單 reset歸零 (0)代表沒有任何object 這不算刪除陣列
      //如果設定為new address[](1); 則代表一開始陣列裡面 就有一個元素
      funders = new address[](0);

      // Transfer
      // msg.sender = address
      // payable(msg.sender) = 可以收費的地址(msg.sender)
      // address(this).balance 這個this代表此合約地址 . 裡面的balance
      //透過Transfer 轉給payable msg.sender
      //payable(msg.sender).transfer(address(this).balance);

      // send
      //bool sendSuccess = payable(msg.sender).send(address(this).balance);
      //require(sendSuccess,"send failed");

      // call
      // 原始的call長這樣 使用call時 會回傳兩個值
      //   call是否成功      call回傳的資料                誰.call{傳入參數} (小括弧是要呼叫的function)
      // (bool callSuccess, bytes memory dataReturned) = someOne.call{}("");

      // 以下用法就是單純得像一般transaction一樣 只是傳送價值  因此 小括弧內是留空 也就是兩個雙引號"" 不呼叫function
      // 且不需要去管Call 回傳的資料  因此刪除dataReturned 只留逗號 傳入的值{} 是此contract的balance
      //  call是否成功 逗號    payable msg.sender  call  傳送值是 this.balance      不呼叫其他的function
      (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
      require(callSuccess,"call failed");
    }

    modifier onlyOwner {
      //require(msg.sender == i_owner,"you are not owner");
      if(msg.sender != i_owner) { revert youNotOwner123(); }
      _;
    }

    receive() external payable {
      fund();
    }

    fallback() external payable {
      fund();
    }

    //使用transfer 將合約中的資產 轉特定金額到外部 特定的一個地址中 需要owner簽署
    function transferFromContract(address payable _to,uint _value) public payable onlyOwner {
      _to.transfer(_value);
    }

    //使用send 將合約中的資產 轉特定金額到外部 特定的一個地址中 需要owner簽署
    function sendFromContract(address payable _to,uint _value) public payable onlyOwner {
      bool sent = _to.send(_value);
      if(sent != true){ revert failed(); }
    }

    //使用call 將合約中的資產 轉特定金額到外部 特定的一個地址中 需要owner簽署
    function callFromContract(address payable _to,uint _value) public payable onlyOwner {
      (bool call,) = _to.call{value: _value}("");
      if(call != true) { revert failed(); }
    }

}
