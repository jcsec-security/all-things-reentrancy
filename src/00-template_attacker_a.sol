// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;


interface IVulnerable {
    function withdraw() external;
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