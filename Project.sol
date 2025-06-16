// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract VotingAndStaking {


    struct Candidate {
        string name;
        uint voteCount;
    }

    address public admin;
    Candidate[] private candidates;
    mapping(address => bool) private voted;

    event CandidateProposed(string name);
    event Voted(address indexed voter, string candidate);
    event WinnerDeclared(string name, uint votes);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function proposeCandidate(string memory _name) external onlyAdmin {
        candidates.push(Candidate(_name, 0));
        emit CandidateProposed(_name);
    }

    function vote(uint index) external {
        require(index < candidates.length, "Invalid candidate");
        require(!voted[msg.sender], "Already voted");

        candidates[index].voteCount++;
        voted[msg.sender] = true;

        emit Voted(msg.sender, candidates[index].name);
    }

    function candidateCount() external view returns (uint) {
        return candidates.length;
    }

    function getCandidate(uint index) external view returns (string memory name, uint votes) {
        require(index < candidates.length, "Invalid index");
        Candidate storage c = candidates[index];
        return (c.name, c.voteCount);
    }

    function getWinner() external view returns (string memory winner, uint highestVotes) {
        require(candidates.length > 0, "No candidates");

        uint maxVotes;
        uint winnerIndex;

        for (uint i = 0; i < candidates.length; i++) {
            if (candidates[i].voteCount > maxVotes) {
                maxVotes = candidates[i].voteCount;
                winnerIndex = i;
            }
        }

        winner = candidates[winnerIndex].name;
        highestVotes = maxVotes;
    }

    

    uint public constant STAKE_AMOUNT = 32 ether;
    mapping(address => bool) public validators;

    event Deposited(address indexed validator);
    event Validated(address indexed validator);

    function deposit() external payable {
        require(msg.value == STAKE_AMOUNT, "Must deposit exactly 32 ETH");
        require(!validators[msg.sender], "Already a validator");

        validators[msg.sender] = true;
        emit Deposited(msg.sender);
    }

    function validate() external {
        require(validators[msg.sender], "Only validators can validate");
        emit Validated(msg.sender);
    }
}
