// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "openzeppelin-contracts/contracts/utils/Counters.sol";

/**
	The same example could be illustrated using ERC777 and a bunch of others
 */
contract Vulnerable is ERC721, ERC721Enumerable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    mapping (address => bool) hasMinted;

    constructor() ERC721("Vulnerable", "VNFT") {}

	function mint() external payable {
		// Checks		
		require(!hasMinted[msg.sender], "Only one NFT per address");
		require(totalSupply() < 10, "All NFTs minted!");
		// _safeMint() perfoms a callback to the recipient's onERC721Received function ==> INTERACTION!!!
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();		
		_safeMint(msg.sender, tokenId);
		// Effects
		hasMinted[msg.sender] = true;

	}

    // This function is an override required by Solidity
    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    // This function is an override required by Solidity
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

}