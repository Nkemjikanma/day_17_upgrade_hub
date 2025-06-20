// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import {SubscriptionStorage} from "./SubscriptionStorage.sol";

contract SubscriptionLogicV1 is SubscriptionStorage {
    error SubscriptionLogicV1__NotEnoughFuns();

    function addSubscriptionPlan(uint256 _planId, uint256 _price, uint256 _duration) external {
        plan[_planId].price = _price;
        plan[_planId].duration = _duration;
        plan[_planId].exists = true;
    }

    function subscribe(uint256 _planId) external payable {
        if (msg.value < plan[_planId].price) {
            revert SubscriptionLogicV1__NotEnoughFuns();
        }

        Subscription storage s = userSubscription[msg.sender];

        if (block.timestamp > s.endDate) {
            s.endDate += plan[_planId].duration;
        } else {
            s.endDate = block.timestamp + plan[_planId].duration;
        }

        s.startDate = block.timestamp;
        s.active = true;
        s.planId = uint8(_planId);
    }

    function isActive(address _user) external view returns (bool) {
        Subscription storage s = userSubscription[_user];

        return s.active;
    }

    function pause(address _user) external {
        Subscription storage s = userSubscription[_user];

        s.active = false;
    }
}
