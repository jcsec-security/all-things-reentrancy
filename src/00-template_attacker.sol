// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;


interface IVulnerable {
    function withdrawAll() external; // You should be able to exploit this one
    function withdrawSome(uint256 amount) external; // Can you exploit this one though? See exercises 04_1 and 04_2 for more on subtraction.
    function deposit() external payable;
}


contract Attacker {

	IVulnerable public target;
	
	constructor(address _target) {
		target = IVulnerable(_target);
	}

    receive() external payable {
        /*
            Your code goes here!
        */
    }

    function exploit() public payable {
        
        /*
            Your code goes here!
        */
    }
}
