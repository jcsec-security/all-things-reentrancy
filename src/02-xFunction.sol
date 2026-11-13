// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";

contract Vulnerable is ReentrancyGuard {

    mapping (address => uint256) balance;
	
    function deposit() external payable {
        balance[msg.sender] += msg.value;
    }

    // Is the reentrancy guard enough?
    function withdraw() external nonReentrant() {		
        require(balance[msg.sender] > 0, "No funds available!");

        (bool success, ) = payable(msg.sender).call{value: balance[msg.sender]}("");
        require(success, "Transfer failed" );

        balance[msg.sender] = 0;
    }
	

    // No external calls here. Safe from reentrancy?
    function transferToInternally(address _recipient, uint _amount) external {
        require(balance[msg.sender] >= _amount, "Not enough funds to transfer!");
        balance[msg.sender] -= _amount;
        balance[_recipient] += _amount;     
    }

    
	function userBalance(address user) public view returns (uint256) {
		return balance[user];
	}

}