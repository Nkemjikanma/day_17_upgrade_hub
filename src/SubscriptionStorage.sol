// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

contract SubscriptionStorage {
    address public owner;
    address public logicContract;

    struct Subscription {
        uint256 planId;
        uint256 startDate;
        uint256 endDate;
        bool active;
    }

    struct Plan {
        uint256 price;
        uint256 duration;
        bool exists;
    }

    mapping(address => Subscription) public userSubscription;
    mapping(uint256 => Plan) public plan;
}
