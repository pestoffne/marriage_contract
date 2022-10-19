// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

abstract contract OwnerDestructable {
    address payable public owner;

    constructor() {
        owner = payable(msg.sender);
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Only owner can call this function.");
        _;
    }

    function destruct() public onlyOwner {
        selfdestruct(owner);
    }

    function transferOwnership(address payable newOwner) public onlyOwner {
        owner = newOwner;
    }
}


struct Couple {
    address spouse1;
    address spouse2;
}


function contains(Couple storage couple, address spouse) view returns (bool) {
    return couple.spouse1 == spouse || couple.spouse2 == spouse;
}


function generateRegistrationNumber(address spouse1, address spouse2) pure returns (uint160) {
    return uint160(spouse1) / 2 + uint160(spouse2) / 2;
}


contract Marriage is OwnerDestructable {
    mapping (address /*proposed keccak256*/ => address[] /*proposers*/) private _proposed_marriages;
    mapping (address /*spouse keccak256*/ => Couple /*spouse1, spouse2*/) public married_couples;

    event proposedMarriage(address proposer, address proposed);
    event acceptedMarriage(address proposer, address proposed);
    //event rejectMarriage(address proposer, address proposed);

    function proposeMarriage(address proposed) public {
        require(!verifyAddressIsMarried(proposed), "Specified address is already married.");
        require(!verifyAddressIsMarried(msg.sender), "Your address is already married.");
        require(!_marriageProposeExists(proposed, msg.sender), "Such marriage propose already exists.");
        require(!_marriageProposeExists(msg.sender, proposed), "There is incoming marriage propose from specified address. Accept it instead.");
        _proposed_marriages[proposed].push(msg.sender);
        emit proposedMarriage(msg.sender, proposed);
    }

    function acceptMarriage(address proposer) public {
        require(!verifyAddressIsMarried(proposer), "Specified address is already married.");
        require(!verifyAddressIsMarried(msg.sender), "Your address is already married.");
        require(_marriageProposeExists(proposer, msg.sender), "Marriage propose from specified address is not found.");
        married_couples[msg.sender] = married_couples[proposer] = Couple({spouse1: proposer, spouse2: msg.sender});
        emit acceptedMarriage(proposer, msg.sender);
    }

    function verifyCoupleIsMarried(address address1, address address2) public view returns (bool) {
        return contains(married_couples[address1], address2);
    }

    function verifyAddressIsMarried(address address1) public view returns (bool) {
        return married_couples[address1].spouse1 != address(0);
    }

    function _marriageProposeExists(address proposer, address proposed) private view returns (bool) {
        for (uint8 i = 0 ; i < _proposed_marriages[proposed].length; i++) {
            if (_proposed_marriages[proposed][i] == proposer) {
                return true;
            }
        }

        return false;
    }
}
