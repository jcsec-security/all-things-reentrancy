// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

/**
	The same example could be illustrated using ERC777 and a bunch of others
 */
contract Vulnerable is ERC721, ERC721Enumerable {

    uint256 private _nextTokenId;
    mapping (address => bool) hasMinted;

    constructor() ERC721("Vulnerable", "VNFT") {}

	function mint() external payable {
		// Checks		
		require(!hasMinted[msg.sender], "Only one NFT per address");
		require(totalSupply() < 10, "All NFTs minted!");
		// _safeMint() perfoms a callback to the recipient's onERC721Received function ==> INTERACTION!!!
        uint256 tokenId = _nextTokenId++;		
		_safeMint(msg.sender, tokenId);
		// Effects
		hasMinted[msg.sender] = true;

	}

    // Function override required by Solidity.
    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721, ERC721Enumerable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    // Function override required by Solidity.
    function _increaseBalance(address account, uint128 value)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._increaseBalance(account, value);
    }

    // Function override required by Solidity.
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

}