// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;


contract Vulnerable_ERC4626 {

	uint256 public constant MIN_BLOCKS_PASSED = 10;

    mapping (address => uint256) balance;
    mapping (address => uint256) user_stake;
    // user -> timestamp in blocks
    mapping (address => uint256) latests_stake;
    uint256 total_shares;        
	
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

	function stake(uint256 amount) external returns (uint256) {
        require(amount > 0, "Can't stake zero");
        require(balance[msg.sender] >= amount, "Not enough funds");
        balance[msg.sender] -= amount;

        uint256 previous_balance = address(this).balance - amount;
        uint256 shares_to_mint = compute_mint(previous_balance, amount, total_shares);     
        
        total_shares += shares_to_mint;
        user_stake[msg.sender] += shares_to_mint;
        latests_stake[msg.sender] = block.number;

        return shares_to_mint;
    }

    function unstake(uint256 amount) external returns (uint256) {
        require(amount > 0, "Can't unstake zero");
        require(user_stake[msg.sender] >= amount, "Not enough stake");
        require(block.number - latests_stake[msg.sender] >= MIN_BLOCKS_PASSED, "Can't unstake yet");

        uint256 current_balance = address(this).balance;
        uint256 eth_retrieved = compute_withdrawal(current_balance, amount, total_shares);

        total_shares -= amount;
        user_stake[msg.sender] -= amount;
        balance[msg.sender] += eth_retrieved;

        return eth_retrieved;
    }

    function compute_mint(
        uint256 current_balance, 
        uint256 in_stk, 
        uint256 current_total_shares
    ) internal pure returns(uint256) {
        if (current_balance != 0) {
            return (current_total_shares * in_stk) / current_balance;
        } else {
            return in_stk;
        }
    }

    function compute_withdrawal(
        uint256 current_balance, 
        uint256 out_stk, 
        uint256 current_total_shares
    ) internal pure returns (uint256) {
        return (out_stk * current_balance) / current_total_shares;
    }


	function userBalance (address _user) public view returns (uint256) {
		return balance[_user];
	}

	function userStake (address _user) public view returns (uint256) {
		return user_stake[_user];
	}

    function getValueOfShares(uint256 amount) public view returns (uint256) { 
        uint256 current_balance = address(this).balance;
        return compute_withdrawal(current_balance, amount, total_shares);
    } 

    function getSharesOfValue(uint256 amount) public view returns (uint256) {
        uint256 current_balance = address(this).balance;
        return compute_mint(current_balance, amount, total_shares);
    }    

}