// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract TrusterAttack {
    error AttackFailed();

    function onFlashLoan() external returns (bool) {
        return true;
        // return abi.encode(false);
        // revert AttackFailed();
    }
}
