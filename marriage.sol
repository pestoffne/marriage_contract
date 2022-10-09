// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

struct Couple {
    address spouse1;
    address spouse2;
}


contract Marriage {
    address payable public root;

    mapping (address /*proposed*/ => address /*proposer*/) _proposed_marriages;
    mapping (address /*spouse*/ => Couple) public married_couples;

    constructor() {
        root = payable(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4);
    }

    modifier rootOnly() {
        require(msg.sender == root, "Only root can call this.");
        _;
    }

    function rootDestruct() public rootOnly {
        selfdestruct(root);
    }

    function generateRegistrationNumber(address spouse1, address spouse2) public pure returns (uint160) {
        return uint160(spouse1) / 2 + uint160(spouse2) / 2;
    }

    event proposedMarriage(address proposer, address proposed);
    event acceptedMarriage(address proposer, address proposed);

    function proposeMarriage(address proposed) public {
        require(_proposed_marriages[msg.sender] != proposed, "Internal marriage propose already exists.");
        //require(married_couples[msg.sender] ..., "Couple is already married.");
        _proposed_marriages[proposed] = msg.sender;
        emit proposedMarriage(msg.sender, proposed);
    }

    function acceptMarriage(address proposer) public {
        require(_proposed_marriages[msg.sender] == proposer, "Specified marriage propose is not found.");
        married_couples[msg.sender] = married_couples[proposer] = Couple({spouse1: proposer, spouse2: msg.sender});
        emit acceptedMarriage(proposer, msg.sender);
    }
}
