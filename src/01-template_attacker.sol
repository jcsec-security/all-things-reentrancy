// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

interface IVulnerable {
	function mint() external payable;
	function totalSupply() external view returns (uint256);
}

contract Attacker {

	IVulnerable public target;
	
	constructor(address _target) {
		target = IVulnerable(_target);
	}

	function onERC721Received(
		address, 
		address, 
		uint256, 
		bytes calldata
	) external returns(bytes4) {
        /*
            Your code goes here!
        */
		return this.onERC721Received.selector;
	}

    function exploit() external {
		
		/*
            Your code goes here!
        */
	}

    
}