// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import "forge-std/Test.sol"; //debug

interface IVulnerable {
    function deposit() external payable;
	function withdraw(uint256 amount) external;	
	function claimKing() external returns (bool);
}


contract Attacker {

	IVulnerable public target;
    bool public retrieving;
	
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