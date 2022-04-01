// SPDX-License-Identifier: none
pragma solidity 0.8.11;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract BioFiNftTest is ERC721URIStorage {
    address public owner;
    address public minter;
    uint256 tokenId;

    constructor() ERC721("BioFiNftTest", "BIOFINFTTEST") {
        owner = msg.sender;
        tokenId = 0;
    }

    function mint(address recipient, string memory tokenURI)
    public
    returns (uint256) {
        require(msg.sender == owner || msg.sender == minter, "Not the owner or minter");
        ++tokenId;
        _mint(recipient, tokenId);
        _setTokenURI(tokenId, tokenURI);
        return tokenId;
    }

    function setMinter(address newMinter) external returns (bool success) {
        success = false;
        require(msg.sender == owner, "Not the owner");
        minter =  newMinter;
        success = true;
    }

}
