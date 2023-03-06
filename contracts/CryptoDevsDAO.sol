// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";


// Interface for the FakeNFTMarketplace Contract
interface IFakeNFTMarketplace{
    // getPrice returns the price of a NFT from the FakeNFTMArketplace
    // return value is the price in wei for a NFT
    function getPrice() external view returns (uint256);

    // available() returns wether or not the given _tokenID has already been purchased
    // return value is true for available or false for not
    function available(uint256 _tokenID) external view returns (bool);
    
    // purchase() purchases a NFT from the FakeNFTMarketplace
    // _tokenID - the fake NFT tokenID to purchase
    function purchase(uint256 _tokenID) external payable;
}

// Minimal Interface for the CryptoDevsNFT 
interface ICryptoDevsNFT{
    // balanceOf() returns the number of NFTs owned by the given adddress
    // owner - address to fetch number of NFTs for
    // return value is the number of NFTs owned
    function balanceOf(address owner) external view returns (uint256);

    // tokenOfOwnerByIndex() returns a tokenID at given inedx for owner
    // owner - address to fetch the NFT tokenID for
    // index - index of NFT in owner tokens array to fetch
    // return value is the tokenID for the NFT at the given index
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

}

contract CryptoDevsDAO is Ownable{

    // struct Proposal with all necessary attributes
    struct Proposal{

        // nftTokenID - the tokenID of the NFT to purchase from FakeNFTMarketplace if the proposal passes
        uint256 nftTokenID;

        // deadline - the UNIX timestamp until which proposal is active. Porposal can be executed after the deadline has been exceeded.abi
        uint256 deadline;

        // yesVotes - number of yes votes for this porposal
        uint256 yesVotes;

        // noVotes - number of no votes for this porposal
        uint256 noVotes;

        // executed - wether or not this porposal has been executed yte. Cannot be executed before the deadline has been exceeded
        bool executed;

        // voters - a mapping of CryptoDevsNFT tokenIDs to booleans indicating wether that NFT has already been used to cats a vote or not
        mapping(uint256 => bool) voters;
    }

    // enum vote that contains the 2 possible options
    enum Vote{
        YES,  //YES = 0
        NO    //NO = 0
    }

    // mapping from ProposalIDs to Proposals
    mapping(uint256 => Proposal) public proposals;
    // number of proposals that have been created
    uint256 public numProposals;



    // Variables for the Interfaces
    IFakeNFTMarketplace nftMarketplace;
    ICryptoDevsNFT cryptoDevsNFT;

    // payable constructor for initializing the contract and set the owner (because of inheritance)
    constructor(address _nftMarketplace, address _cryptoDevsNFT) payable
    {
        nftMarketplace = IFakeNFTMarketplace(_nftMarketplace);
        cryptoDevsNFT = ICryptoDevsNFT(_cryptoDevsNFT);
    }


    // custom modifier which only allows a function to be called by someone who owns CryptoDevs NFTs
    modifier nftHolderOnly()
    {
        require(cryptoDevsNFT.balanceOf(msg.sender) > 0, "Not a DAO Mebmer!");
        _;
    }

    // custom modifier which allows functions only to be called, if the given ProposalsDeadline has not beent exceeded yet
    modifier activeProposalOnly(uint256 proposalIndex)
    {
        require(proposals[proposalIndex].deadline > block.timestamp, "Deadline exceeded!");
        _;
    }

    // custom modifier which only allows a function to be called, if the given proposals deadline has been exceeded and if the porposal has not yet been executed
    modifier inactiveProposalOnly(uint256 proposalIndex)
    {
        require(proposals[proposalIndex].deadline <= block.timestamp, "Deadline not exceeded!");
        require(proposals[proposalIndex].executed == false, "Proposal already has been executed");
        _;
    }


    // createProposal allows a CryptoDevs NFT-holder to create a proposal in the DAO
    // _nftTokenID - the tokenID of the NFT to be purchased from FakeNFTMarketplace if this proposal passes
    // return value is the index for the new created porposal in the proposals mapping
    function createProposal(uint256 _nftTokenID) external nftHolderOnly returns (uint256)
    {
        require(nftMarketplace.available(_nftTokenID), "NFT is not available");
        Proposal storage proposal = proposals[numProposals];
        proposal.nftTokenID = _nftTokenID;
        // Set the proposals voting deadline to be in 30 minutes
        proposal.deadline = block.timestamp + 5 minutes;

        numProposals++;

        return numProposals - 1;
    }


    // voteOnProposal allows a CryptoDevs NFT-holder to cats their vote on an active proposal
    // proposalIndex - the index of the porposal to vote on in the proposals array
    // vote - the type of vote they want to cast
    function voteOnProposal(uint256 proposalIndex, Vote vote) external nftHolderOnly activeProposalOnly(proposalIndex)
    {
        Proposal storage proposal = proposals[proposalIndex];

        uint256 voterNFTBalance = cryptoDevsNFT.balanceOf(msg.sender);
        uint256 numVotes = 0;

        // Calculate how many NFTs owned by the voter, that not has already been used as a right to vote
        for(uint256 i = 0; i < voterNFTBalance; i++)
        {
            uint256 tokenID = cryptoDevsNFT.tokenOfOwnerByIndex(msg.sender, i);
            if(proposal.voters[tokenID] == false)
            {
                numVotes++;
                proposal.voters[tokenID] = true;
            }
        }

        require(numVotes > 0, "Already voted!");

        if(vote == Vote.YES)
        {
            proposal.yesVotes += numVotes;
        }
        else 
        {
            proposal.noVotes += numVotes;    
        }
    }

    // executeProposal allows only CryptoDevs NFT-holders to execute a proposal after it's deadline has been exceeded
    // proposalIndex - the index of the porposal to excute in the proposals array
    function executeProposal(uint256 proposalIndex) external nftHolderOnly inactiveProposalOnly(proposalIndex)
    {

        Proposal storage proposal = proposals[proposalIndex];

        // If the proposal has more YES than NO votes, purchase the NFT from the FakeNFTMarketplace
        if(proposal.yesVotes > proposal.noVotes)
        {
            uint256 nftPrice = nftMarketplace.getPrice();
            require(address(this).balance >= nftPrice, "Not enough funds to purchase NFT!");
            nftMarketplace.purchase{value: nftPrice}(proposal.nftTokenID);
        }
        proposal.executed = true;
    }

    function withdrawEther() external onlyOwner
    {
        uint256 amount = address(this).balance;
        require(amount > 0, "Nothing to withdraw, contract balance empty");
        payable(owner()).transfer(amount);
    }

    receive() external payable {}

    fallback() external payable {}
}