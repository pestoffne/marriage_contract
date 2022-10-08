// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

struct Couple {
    address husband;
    address wife;
    //bytes registration_number;
}

contract Marriage {
    address payable public root;
    mapping (address /*proposed*/ => address /*proposer*/) proposed_marriages;
    mapping (address /*spouse*/ => Couple) public married_couples;

    constructor() {
        root = payable(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4);
    }

    function root_destruct() public {
        require(msg.sender == root);
        selfdestruct(root);
    }

    function generate_registration_number(address husband, address wife) public pure returns (uint160) {
        return uint160(husband) / 2 + uint160(wife) / 2;
    }

    function propose_marriage(address proposed) public {
        proposed_marriages[proposed] = msg.sender;
        //emit 
    }

    function accept_marriage(address proposer) public {
        require(proposed_marriages[msg.sender] == proposer);
        married_couples[msg.sender] = married_couples[proposer] = Couple({husband: proposer, wife: msg.sender});
        //emit
    }
}
