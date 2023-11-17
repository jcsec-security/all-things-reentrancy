// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";


interface ILiquidityPool {
	function getSpotPriceStEth(uint256 amount) external view returns (uint256);
}


contract ReaderLender is ReentrancyGuard () {
   
	struct Loan {
		uint256 amount;
		uint256 collateral;
	}

	
	uint256 private constant FEE_PERCENTAGE = 5;
	uint256 private constant OVERCOLLATERALLIZATION_PERCENTAGE = 150;
	mapping(address => Loan) public loans;
	IERC20 public atrToken;
	ILiquidityPool public pool;


	constructor(address token_address, address _pool) {
		atrToken = IERC20(token_address);
		pool = ILiquidityPool(_pool); // Is this a trusted source? will it have vulnerabilities?
	}	

	function borrowStEth(uint256 amount) external payable {
		require(loans[msg.sender].amount == 0, "You already have a loan");

		uint256 price = pool.getSpotPriceStEth(amount);
		uint256 required_collateral = price * OVERCOLLATERALLIZATION_PERCENTAGE / 100;
		require(required_collateral > 0, "Requested amount is not high enough");

		uint256 collateral_with_fee = price * (OVERCOLLATERALLIZATION_PERCENTAGE + FEE_PERCENTAGE) / 100;
		require(msg.value >= collateral_with_fee, "Not enough collateral");
		
		loans[msg.sender] = Loan(amount, required_collateral);
		atrToken.transfer(msg.sender, amount);
	}

	function repay() external payable {
		require(loans[msg.sender].amount != 0, "You don't have a loan");
		
		uint256 steth_lent = loans[msg.sender].amount;
		uint256 eth_to_return = loans[msg.sender].collateral;
		delete loans[msg.sender];

		atrToken.transferFrom(msg.sender, address(this), steth_lent);

		(bool success, ) = payable(msg.sender).call{value: eth_to_return}("");
		require(success, "Repay's transfer failed");
	}

	/*
	 * Liquidations out of the scope of this example
	*/

}
