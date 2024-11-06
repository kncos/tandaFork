// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ITandaPayFactory {
    function createCommunity(address paymentToken) external returns(address newCommunity);
}