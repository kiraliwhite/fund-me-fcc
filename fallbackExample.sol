// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract ReceiveExample {

    uint public testData;
    receive() external payable {
        testData = 1;
    }

    fallback() external payable {
        testData = 2;
    }
}
