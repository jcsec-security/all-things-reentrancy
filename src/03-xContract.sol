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


    function deposit() external payable nonReentrant() {
		require(msg.value > 0, "Funds not sent!");
		stEthToken.mint(msg.sender, msg.value);
    }


	// Last minute fn without security patterns in mind, just relying on the modifier
    function withdraw() external nonReentrant() {	
		uint256 usr_balance = stEthToken.balanceOf(msg.sender);
        require(usr_balance > 0, "No funds available!");

        (bool success, ) = payable(msg.sender).call{value: usr_balance}("");
        require(success, "Eth transfer failed" );

        stEthToken.burnAll(msg.sender); // Was it CEI or CIE? Not sure... :P
	}
	
	// No need to use this old fn, now we have ERC20.transfer()!
    //function transferToInternally(address _recipient, uint _amount) external { 
    //    ...
	//}
}
