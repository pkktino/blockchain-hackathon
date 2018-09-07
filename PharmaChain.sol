// solium-disable linebreak-style
pragma solidity ^0.4.24;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

    /**
    * @dev Multiplies two numbers, reverts on overflow.
    */
    function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (_a == 0) {
            return 0;
        }

        uint256 c = _a * _b;
        require(c / _a == _b, "Invalid math");

        return c;
    }

    /**
    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
        require(_b > 0, "Invalid math"); // Solidity only automatically asserts when dividing by 0
        uint256 c = _a / _b;
        // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
        require(_b <= _a, "Invalid math");
        uint256 c = _a - _b;

        return c;
    }

    /**
    * @dev Adds two numbers, reverts on overflow.
    */
    function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
        uint256 c = _a + _b;
        require(c >= _a, "Invalid math");

        return c;
    }

    /**
    * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "Invalid math");
        return a % b;
    }
}

contract PharmaChain {
    
    using SafeMath for uint;
    
    enum Role { Goverment, Patient, DrugStore, Pharmacy, Doctor, Invalid }
    
    mapping(address => uint256) accountOwner;
    mapping(address => uint) ownerAccountCount;
    
    struct Account {
        string name;
        Role role;
    }
    
    struct Prescription {
        address owner;
        address delegate;
        address assignedDoctor;
        address[] assignedPharmacy;
        string[] medicines;
        string remark;
        mapping(string => uint) orderedMeds;
        mapping(string => uint) receivedMeds;
    }
    
    Account[] accounts;
    Prescription[] prescriptions;
    
    function registerAccount(string _name, string _role) public {
        require(ownerAccountCount[msg.sender] == 0, "Sender already has an account");
        
        Role role = getRole(_role);
        require(role != Role.Invalid, "Invalid role");

        uint id = accounts.push(Account(_name, role)) - 1;
        accountOwner[msg.sender] = id;
        ownerAccountCount[msg.sender]++;
    }

    function createPrescription(address _owner) public returns (uint) {
        require(isDoctor(msg.sender), "Only doctor role is allowed to create prescriptions");
        uint id = prescriptions.push(Prescription(_owner, 0, msg.sender, new address[](0), new string[](0), "")) - 1;
        return (id);
    }

    function addMedicineToPrescription(uint _id, string _medicineName, uint _amount) public {
        require(isDoctor(msg.sender), "Only doctor role is allowed to add medicine to prescriptions");
        Prescription storage prescription = prescriptions[_id];
        if (prescription.orderedMeds[_medicineName] <= 0) {
            prescription.medicines.push(_medicineName);
        }
        prescription.orderedMeds[_medicineName].add(_amount);
    }

    function setDelegator(uint _pid, address _delegator) public {
        require(isPatient(msg.sender), "Only patient can set prescription delegator");
        Prescription storage prescription = prescriptions[_pid];
        require(prescription.owner == msg.sender, "Only owner can set delegator");
        prescription.delegate = _delegator;
    }

    function sellMedicine(uint _pid, address _buyer, string _medicineName, uint amount) public {
    }

    // Helper functions
    function isGoverment(address user) internal view returns (bool) {
        return (Role.Goverment == getRoleFromAddress(user));
    }

    function isPatient(address user) internal view returns (bool) {
        return (Role.Patient == getRoleFromAddress(user));
    }

    function isDrugStore(address user) internal view returns (bool) {
        return (Role.DrugStore == getRoleFromAddress(user));
    }

    function isPharmacy(address user) internal view returns (bool) {
        return (Role.Pharmacy == getRoleFromAddress(user));
    }

    function isDoctor(address user) internal view returns (bool) {
        return (Role.Doctor == getRoleFromAddress(user));
    }

    function getRoleFromAddress(address user) internal view returns (Role) {
        uint index = accountOwner[user];
        return accounts[index].role;
    }

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

