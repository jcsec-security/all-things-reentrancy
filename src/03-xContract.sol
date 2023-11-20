// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;


import "openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";


interface IERC20BurnableMintable {
	function mint(address to, uint256 amount) external;
	function burnAll(address account) external;
	function balanceOf(address account) external view returns (uint256);
}


contract Vulnerable is ReentrancyGuard {

	IERC20BurnableMintable public stEthToken;	

	constructor(address token_address) {
		stEthToken = IERC20BurnableMintable(token_address);
	}


    function stake() external payable nonReentrant() {
		require(msg.value > 0, "Funds not sent!");
		stEthToken.mint(msg.sender, msg.value);
    }


    function unstake() external nonReentrant() {// Last minute fn without security patterns in mind, just relying on the modifier	
		uint256 usr_balance = stEthToken.balanceOf(msg.sender);
        require(usr_balance > 0, "No funds available!");

        (bool success, ) = payable(msg.sender).call{value: usr_balance}("");
        require(success, "Eth transfer failed" );

        stEthToken.burnAll(msg.sender); // Was it CEI or CIE? Not sure... :P
	}
	
}
