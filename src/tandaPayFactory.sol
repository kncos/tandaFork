// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./TandaPay.sol";

contract TandaPayFactory {
    event NewCommunity(address newCommunity);
    address[] public TandaPayCommunities;
    
    /**
     * @dev creates a new tandapay community
     * @notice caller becomes secretary
     * @param paymentToken address of of the erc20 token used for payment
     */
    function createCommunity(address paymentToken) external returns(address newCommunity) {
        TandaPay community = new TandaPay(paymentToken, msg.sender);
        TandaPayCommunities.push(address(community));
        newCommunity = address(community);
        emit NewCommunity(newCommunity);
    }
}