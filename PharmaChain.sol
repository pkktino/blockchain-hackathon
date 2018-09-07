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
    
    enum Role { Goverment, Patient, DrugStore, Pharmacy, Doctor, Invalid }
    
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
    
    function registerAccount(string _name, string _role) public {
        require(ownerAccountCount[msg.sender] == 0, "Sender already has an account");
        
        Role role = getRole(_role);
        require(role != Role.Invalid, "Invalid role");

        uint id = accounts.push(Account(_name, role)) - 1;
        accountOwner[msg.sender] = id;
        ownerAccountCount[msg.sender]++;
    }

    // Helper functions
    function getRole(string role) internal pure returns (Role) {
        if (compareStrings(role, "Goverment")) return Role.Goverment;
        if (compareStrings(role, "Patient"))   return Role.Patient;
        if (compareStrings(role, "DrugStore")) return Role.DrugStore;
        if (compareStrings(role, "Pharmacy"))  return Role.Pharmacy;
        if (compareStrings(role, "Doctor"))    return Role.Doctor;
        return Role.Invalid;
    }

    function compareStrings(string a, string b) internal pure returns (bool) {
        return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
    }

}

