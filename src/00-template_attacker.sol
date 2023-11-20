// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;


interface IVulnerable {
    function withdrawAll() external; // You should be able to exploit this one
    function withdrawSome(uint256 amount) external; // Can you  exploit this one though? check 02-basic_b for more on this
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