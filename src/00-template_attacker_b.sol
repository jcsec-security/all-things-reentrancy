// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;


interface IVulnerable {
    function withdrawAll() external;
	function withdrawSome(uint256 amount) external;
    function deposit() external payable;
    function isUserVip (address user) external view returns (bool);
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
    
    function getTheMoney() external returns (uint256) {
        /*
            Your code goes here!
        */
    }
}