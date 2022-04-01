// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
 
import "https://github.com/0xcert/ethereum-erc721/src/contracts/tokens/nf-token-metadata.sol";
import "https://github.com/0xcert/ethereum-erc721/src/contracts/ownership/ownable.sol";
 
contract SeqNFT is NFTokenMetadata, Ownable {
 
   uint256 tokenId;
   address minter;

  constructor() {
    nftName = "VHUE NFT";
    nftSymbol = "VHUENFT";
    tokenId = 1;
  }

  function mint(address _to, string calldata _uri) external {
    require(msg.sender == owner || msg.sender == minter, "Not the owner or minter");
    ++tokenId;  
    super._mint(_to, tokenId);
    super._setTokenUri(tokenId, _uri);
  }

  function setMinter(address newMinter) external returns (bool success) {
    success = false;
    require(msg.sender == owner, "Not the owner");
    minter =  newMinter;
    success = true;
  }
 
}
