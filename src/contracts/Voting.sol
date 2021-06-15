//SPDX-License-Identifier: GPL-3.0
pragma solidity >= 0.7.0 < 0.9.0;

///@title voting with delegation
contract Voting {

    //Represent a single voter
    struct Voter {
        uint weight; //weight is accumulated by delegation
        uint vote; //Index of the voted proposal
        bool voted; //If true the person has already voted
        address delegate; //Person delegated to
    }

    //Type for a single proposal to be voted on
    struct Proposal {
        bytes32 name; 
        uint voteCount; //number of accumulated votes
    }

    address public chairperson;

    //Store a single "Voter" struct for each possible address
    mapping(address => Voter) public voters;

    //Dynamically sized-array of "Proposal" structs
    Proposal[] public proposals;

    //Create a  new ballot to choose one of "ProposalNames"
    constructor (bytes32[] memory proposalNames) {
        chairperson = msg.sender;
        voters[chairperson].weight = 1;

        //For each of the provided proposal names, create a new proposal object and add it to the end of the end of the array
        for(uint i = 0; i<proposalNames.length; i++) {
            proposals.push(Proposal({name: proposalNames[1], voteCount: 0}));
        }

    }

    //Give voter right to vote
    //May only be called by chairperson

    function giveRightToVote(address voter) public {
        require(msg.sender == chairperson, "Only chairperson can give the right to vote");
        require(!voters[voter].voted, "The voter has already voted");
        require(voters[voter].weight == 0);
        voters[voter].weight = 1;
    }

    //Delegate your vote to the Voter 'to'
    function delegate (address to) public {
        //Assigns a reference
        Voter storage sender = voters[msg.sender];
        require(!sender.voted, "You already voted");
        require(to != msg.sender, "You cannot self-delegate");

        //Forward the delegation as long as 'to' also delegated
        while (voters[to].delegate != address(0)){
            to = voters[to].delegate;

            //We found a loop in delegation, not allowed
            require(to != msg.sender, "Found a loop in delegation");
        }

        //Since sender is a reference, this modifies 'voters[msg.sender].voted'
        sender.voted = true;
        sender.delegate = to;
        Voter storage delegate_ = voters[to];

        if (delegate_.voted) {
            //If delegate has already voted, directly add to the number of votes
            proposals[delegate_.vote].voteCount += sender.weight;
        } else {
            //If delegate hasn't voted already, add to their weight
            delegate_.weight += sender.weight;
        }
    }

    //Compute the winning proposal taking into account all the previous votes into account
    function winningProposal() public view returns(uint winningProposal_) {
        uint winningVoteCount = 0;
        for(uint p = 0; p < proposals.length; p++) {
            if(proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                winningProposal_ = p;
            }
        }
    }

    //Calls the winningProposal() function to get the name of the winner

    function winnerName() public view returns(bytes32 winnerName_) {
        winnerName_ = proposals[winningProposal()].name;
    }

}