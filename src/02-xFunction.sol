// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";

contract Vulnerable is ReentrancyGuard {

    mapping (address => uint256) balance;
	
    function deposit() external payable {
        balance[msg.sender] += msg.value;
    }

    // The guard covers protected entry points, not every function that shares balance.
    function withdraw() external nonReentrant() {		
        require(balance[msg.sender] > 0, "No funds available!");

        (bool success, ) = payable(msg.sender).call{value: balance[msg.sender]}("");
        require(success, "Transfer failed" );

        balance[msg.sender] = 0; // Was it CEI or CIE? Not sure... :P
    }
	

    // No external call here, but this still changes the accounting used by withdraw()!
    function transferToInternally(address _recipient, uint _amount) external {
        require(balance[msg.sender] >= _amount, "Not enough funds to transfer!");
        balance[msg.sender] -= _amount;
        balance[_recipient] += _amount;     
    }

    
	function userBalance(address user) public view returns (uint256) {
		return balance[user];
	}

}