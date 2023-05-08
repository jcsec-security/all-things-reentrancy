// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/security/ReentrancyGuard.sol";

interface IERC20BurnableMintable {
	function mint(address to, uint256 amount) external;
	function burn(address from, uint256 amount) external;
	function balanceOf(address account) external view returns (uint256);
    function totalSupply() external view returns (uint256);
}

/*
* @notice I quickly simplified an implementation from a random GH repo, do not trust this implementation
*/
contract VulnerableLiquidityPool is ReentrancyGuard {

    IERC20 public immutable stEth;
    IERC20BurnableMintable public immutable lpToken;


    constructor(address steth_token, address lp_token) {
        stEth = IERC20(steth_token);
        lpToken = IERC20BurnableMintable(lp_token);
    }


    function addLiquidity(uint256 stEth_amount, uint256 eth_amount)
        external
        payable
        nonReentrant()
        returns (uint256)
    {
        require(
            stEth.transferFrom(msg.sender, address(this), stEth_amount),
            "stEth Transfer Failed"
        );
        require(
            msg.value == eth_amount,
            "Insufficient Eth transfer"
        );

        /*
        Check if the ratio of tokens supplied is proportional
        to reserve ratio to satisfy x * y = k for price to not
        change if both reserves are greater than 0
        */

        uint256 stEth_reserve = stEth.balanceOf(address(this)) - stEth_amount;
        uint256 eth_reserve = address(this).balance - eth_amount;

        if (stEth_reserve > 0 || eth_reserve > 0) {
            require(
                eth_amount * stEth_reserve == stEth_amount * eth_reserve,
                "Unbalanced Liquidity Provided"
            );
        }

        /*
        Calculate number of liquidity shares to mint using
        the geometric mean as a measure of liquidity. Increase
        in liquidity is proportional to increase in shares
        minted.
        > S = (dx / x) * TL
        > S = (dy / y) * TL
        NOTE: Amount of liquidity shares minted formula is similar
        to Uniswap V2 formula. For minting liquidity shares, we take
        the minimum of the two values calculated to incentivize depositing
        balanced liquidity.
        */
        uint256 totalLiquidity = lpToken.totalSupply();
        uint256 lp_amount;

        if (totalLiquidity == 0) {
            lp_amount = sqrt(stEth_amount * eth_amount);
        } else {
            lp_amount = min(
                ((stEth_amount * totalLiquidity) / stEth_reserve),
                ((eth_amount * totalLiquidity) / eth_reserve)
            );
        }

        require(lp_amount > 0, "No Liquidity Shares Minted");
        // Mint shares to user
        lpToken.mint(msg.sender, lp_amount);

        return lp_amount;
    }


    function removeLiquidity(uint256 lp_amount)
        external
        nonReentrant()
        returns (uint256, uint256)
    {
        require(
            lpToken.balanceOf(msg.sender) >= lp_amount,
            "Insufficient liquidity shares"
        );

        // Get balance of both tokens
        uint256 stEth_balance = stEth.balanceOf(address(this));
        uint256 eth_balance = address(this).balance;
        uint256 totalLiquidity = lpToken.totalSupply();

        uint256 stEth_amount = (lp_amount * stEth_balance) / totalLiquidity;
        uint256 eth_amount = (lp_amount * eth_balance) / totalLiquidity;

        require(
            stEth_amount > 0 && eth_amount > 0,
            "Insufficient transfer amounts"
        );

        // Burn user liquidity shares
        lpToken.burn(msg.sender, lp_amount);
        // Transfer tokens to user
        (bool success, ) = payable(msg.sender).call{value: eth_amount}("");
        require(success, "Transfer failed");
        stEth.transfer(msg.sender, stEth_amount);

        return (stEth_amount, eth_amount);
    }

    // Internal function to square root a value from Uniswap V2
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    // Internal function to find minimum value from Uniswap V2
    function min(uint256 x, uint256 y) internal pure returns (uint256) {
        return x < y ? x : y;
    }

    function getSpotPriceStEth(uint256 amount) public view returns (uint256) {
        return amount * address(this).balance / stEth.balanceOf(address(this));
    }

    function getSpotPriceEth(uint256 amount) public view returns (uint256) {
        return amount * stEth.balanceOf(address(this)) / address(this).balance;
    }
}