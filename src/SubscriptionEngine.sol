// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;
import {SubscriptionStorage} from "./SubscriptionStorage.sol";

// users interact with this but it delegats logic to logic contract
contract SubscriptionEngine is SubscriptionStorage {
    error SubscriptionEngine__NotOwner();
    error SubscriptionEngine__InvalidLogicAddress();

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert SubscriptionEngine__NotOwner();
        }
        _;
    }

    //pass address of logic contract
    constructor(address _logicContract) {
        owner = msg.sender;
        logicContract = _logicContract;
    }

    function upgradeEngineContract(
        address _newLogicContract
    ) external onlyOwner {
        logicContract = _newLogicContract;
    }

    // It’s a special function that gets triggered whenever a user calls a function that doesn’t exist in this proxy contract
    fallback() external payable {
        address impl = logicContract;

        if (impl == address(0)) {
            revert SubscriptionEngine__InvalidLogicAddress();
        }

        assembly {
            // Copy the input data (function signature + arguments) to memory slot 0
            calldatacopy(0, 0, calldatasize())

            // delegatecall runs the logic code, but uses this proxy’s storage and this proxy’s context.
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)

            // Copy whatever came back from the logic contract’s execution to memory.
            // Could be a return value or an error message.
            returndatacopy(0, 0, returndatasize())

            // if logic fails, revert and return the error
            // else return the result back to original caller - as if proxy executed
            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    // A safety net that lets the proxy accept raw ETH transfers.
    receive() external payable {}
}
