// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FakeNFTMarketplace{
    
    //Maintain a mapping of fake TokenID to owner addresses
    mapping(uint256 => address) public tokens;
    //Set thee purchase price for each fake NFT
    uint256 nftPrice = 0.1 ether;

    // purchase() accpets ETH and marks the owner of the given tokenID as the caller address
    // _tokenID - the fake NFT token ID to purchase
    function purchase(uint256 _tokenID) external payable{
        require(msg.value == nftPrice, "This NFT costs 0.1 ether");
        tokens[_tokenID] = msg.sender;
    }

    // getPrice returns the price of one NFT
    function getPrice() external view returns (uint256)
    {
        return nftPrice;
    }

    // available() checks wether the given tokenID has already been sold or not
    // _tokenID - the tokenID to check for
    function available(uint256 _tokenID) external view returns (bool)
    {
        // address(0) = 0x0000000000000000000000000000000000000000
        // This is the default value for addresses in solidity
        if(tokens[_tokenID] == address(0))
        {
            return true;
        }
        return false;
    }
}