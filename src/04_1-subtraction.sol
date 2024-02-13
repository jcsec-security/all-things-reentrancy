// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;


contract Vulnerable {

    struct King {
        address addr;
        uint256 amount;
    }

	uint256 public constant MIN_BLOCKS_PASSED = 10;

    mapping (address => uint256) balance;
    King public king;  
	

    receive() external payable {}


    function deposit() external payable {
        balance[msg.sender] += msg.value;
    }


	function withdraw(uint256 amount) external {		
		// Checks!
        require(amount > 0, "Can't withdraw zero");
		require(balance[msg.sender] >= amount, "Not enough funds");	
		// Interactions D: VULNERABLE!!... but exploitable?
		(bool success, ) = payable(msg.sender).call{value: amount}("");
		require(success, "Low level call failed");
		// Effects :(
		balance[msg.sender] -= amount;	
	}	

	function claimKing() external returns (bool) {
        require(balance[msg.sender] > king.amount, "There was a mightier king...");
        
        king.addr = msg.sender;
        king.amount = balance[msg.sender];

        return true;
    }


    function userBalance(address user) public view returns (uint256) {
        return balance[user];
    }


    function whoIsTheKing() public view returns (King memory) {
        return king;
    }

}