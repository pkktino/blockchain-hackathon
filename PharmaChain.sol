// solium-disable linebreak-style
pragma solidity ^0.4.24;

/**
 * Math operations with safety checks
 */
library SafeMath {
    function mul(uint a, uint b) internal returns (uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint a, uint b) internal returns (uint) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint a, uint b) internal returns (uint) {
        assert(b <= a);
        return a - b;
    }

    function add(uint a, uint b) internal returns (uint) {
        uint c = a + b;
        assert(c >= a);
        return c;
    }

    function max64(uint64 a, uint64 b) internal view returns (uint64) {
        return a >= b ? a : b;
    }

    function min64(uint64 a, uint64 b) internal view returns (uint64) {
        return a < b ? a : b;
    }

    function max256(uint256 a, uint256 b) internal view returns (uint256) {
        return a >= b ? a : b;
    }

    function min256(uint256 a, uint256 b) internal view returns (uint256) {
        return a < b ? a : b;
    }

    function assert(bool assertion) internal {
        if (!assertion) {
            revert();
        }
    }
}

contract Bank {
    
    using SafeMath for uint;
    
    enum Role { Goverment, Patient, DrugStore, Pharmacy, Doctor }
    
    mapping(address => uint256) accountOwner;
    mapping(address => uint) ownerAccountCount;
    
    struct Account{
        string name;
        Role role;
    }
    
    struct Prescription {
        address owner;
        address delegate;
        address assignedDoctor;
        address[] assignedPharmacy;
        mapping(string => uint) medicine;
        mapping(string => uint) receivedMedicine;
        string remark;
    }
    
    Account[] accounts;
    
    function registerAccount(string _name) public{
        require(ownerAccountCount[msg.sender] == 0);
        uint id = accounts.push(Account(_name,0,0)) - 1;
        accountOwner[msg.sender] = id;
        ownerAccountCount[msg.sender]++;
    }
    
    function balanceOf() public view returns (uint256) {
        uint currentId = accountOwner[msg.sender];
        return accounts[currentId].balance;
    }
    
    function increaseYear(uint256 year) public{
        uint currentId = accountOwner[msg.sender];
        accounts[currentId].year += year;
        if(accounts[currentId].year >= 1){
            for (uint i=0; i<accounts[currentId].year; i++) {
                accounts[currentId].balance += ((accounts[currentId].balance*10)/100);
            }
        }
    }
    
    function depositMoney() public payable{
        uint currentId = accountOwner[msg.sender];
        accounts[currentId].balance = accounts[currentId].balance.add(msg.value);
    }
    
    function withdrawMoney(uint256 amount) public{
        uint currentId = accountOwner[msg.sender];
        require(accounts[currentId].balance >= amount);
        accounts[currentId].balance = accounts[currentId].balance.sub(amount);
        msg.sender.transfer(amount);
    }
    
    function displayAccountDetail() public view returns(
        string _name,
        uint256 _balance,
        uint256 _year)
    {
        uint currentId = accountOwner[msg.sender];
        _name = accounts[currentId].name;
        _balance = accounts[currentId].balance;
        _year = accounts[currentId].year;
    }
}

