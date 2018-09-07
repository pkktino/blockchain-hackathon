// solium-disable linebreak-style
pragma solidity ^0.4.24;
pragma experimental ABIEncoderV2;

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
        mapping(address => bool) hasPharmacy;
    }
    
    Account[] accounts;
    Prescription[] prescriptions;

    mapping(address => uint[]) historyIdList;
    mapping(address => mapping(uint => bool)) isInHistory;
    
    function registerAccount(string _name, string _role) public {
        require(ownerAccountCount[msg.sender] == 0, "Sender already has an account");
        
        Role role = getRole(_role);
        require(role != Role.Invalid, "Invalid role");

        uint id = accounts.push(Account(_name, role)) - 1;
        accountOwner[msg.sender] = id;
        ownerAccountCount[msg.sender]++;
    }

    function createPrescription(address _owner) public hasRegistered returns (uint) {
        require(isDoctor(msg.sender), "Only doctor role is allowed to create prescriptions");
        uint id = prescriptions.push(Prescription(_owner, 0, msg.sender, new address[](0), new string[](0), "")) - 1;
        addAddressToMap(msg.sender, id);
        addAddressToMap(_owner, id);
        return (id);
    }
    
    function addMedicineToPrescription(uint _id, string _medicineName, uint _amount) public hasRegistered {
        require(isDoctor(msg.sender), "Only doctor role is allowed to add medicine to prescriptions");
        require(isPrescriptionAssigner(msg.sender, _id), "Only assigned doctor can add medicine to prescriptions");
        if (prescriptions[_id].orderedMeds[_medicineName] <= 0) {
            prescriptions[_id].medicines.push(_medicineName);
        }
        prescriptions[_id].orderedMeds[_medicineName].add(_amount);
    }

    function setDelegator(uint _pid, address _delegator) public hasRegistered {
        require(isPatient(msg.sender), "Only patient can set prescription delegator");
        require(prescriptions[_pid].owner == msg.sender, "Only owner can set delegator");
        prescriptions[_pid].delegate = _delegator;
    }

    function sellMedicine(uint _pid, address _buyer, string _medicineName, uint _amount) public hasRegistered returns (bool) {
        require(isPrescriptionOwner(_buyer, _pid), "Only owner or delegator can buy drugs");
        uint received = prescriptions[_pid].receivedMeds[_medicineName];
        uint ordered = prescriptions[_pid].orderedMeds[_medicineName];
        require(received.add(_amount) <= ordered, "Cannot buy more than ordered");
        Prescription storage prescription = prescriptions[_pid];
        prescription.receivedMeds[_medicineName] = received.add(_amount);
        prescription.assignedPharmacy.push(msg.sender);
        prescription.hasPharmacy[msg.sender] = true;
        addAddressToMap(msg.sender, _pid);
    }

    // Readonly functions
    function userGetPrescription() public hasRegistered view returns (uint[]) {
        return historyIdList[msg.sender];
    }
    
    function getPrescription(uint id) public hasRegistered view returns (string, string, string[], uint[], uint[]) {
        require(id <= prescriptions.length, "Invalid id");
        string memory _name = accounts[accountOwner[prescriptions[id].owner]].name;
        string memory _assignDoctor = accounts[accountOwner[prescriptions[id].assignedDoctor]].name;
        string[] memory _medicines = prescriptions[id].medicines;
        uint[] memory _orderedMeds;
        uint[] memory _receivedMeds;

        for(uint i = 0 ; i < _medicines.length ; i++){
            _orderedMeds[i] = prescriptions[id].orderedMeds[_medicines[i]];
            _receivedMeds[i] = prescriptions[id].receivedMeds[_medicines[i]];
        }
        
        return (_name, _assignDoctor, _medicines, _orderedMeds, _receivedMeds);
    }

    // Helper functions
    function addAddressToMap(address user, uint id) internal {
        if (!(isInHistory[user][id])) {
            historyIdList[user].push(id);
            isInHistory[user][id] = true;
        }
    }

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

    function isPrescriptionAssigner(address user, uint id) internal view returns (bool) {
        return (prescriptions[id].assignedDoctor == user);
    }

    function isPrescriptionOwner(address user, uint id) internal view returns (bool) {
        return (prescriptions[id].owner == user || prescriptions[id].delegate == user);
    }

    function isPrescriptionPharmacy(address user, uint id) internal view returns (bool) {
        return prescriptions[id].hasPharmacy[user];
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

    modifier hasRegistered() {
        require(ownerAccountCount[msg.sender] > 0, "User have not registered");
        _;
    }
}

