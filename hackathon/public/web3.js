var account = [];
var _web3 = undefined;
var interestRate = 1.015;
var tokenAddr = "0x3c2becbc7ec249553036c6d65c8672b7587621c5"

function getSmartContract() {
    var abi = [
        {
            "constant": false,
            "inputs": [
                {
                    "name": "_id",
                    "type": "uint256"
                },
                {
                    "name": "_medicineName",
                    "type": "string"
                },
                {
                    "name": "_amount",
                    "type": "uint256"
                }
            ],
            "name": "addMedicineToPrescription",
            "outputs": [],
            "payable": false,
            "stateMutability": "nonpayable",
            "type": "function"
        },
        {
            "constant": false,
            "inputs": [
                {
                    "name": "_owner",
                    "type": "address"
                }
            ],
            "name": "createPrescription",
            "outputs": [],
            "payable": false,
            "stateMutability": "nonpayable",
            "type": "function"
        },
        {
            "constant": false,
            "inputs": [
                {
                    "name": "_name",
                    "type": "string"
                },
                {
                    "name": "_role",
                    "type": "string"
                }
            ],
            "name": "registerAccount",
            "outputs": [],
            "payable": false,
            "stateMutability": "nonpayable",
            "type": "function"
        },
        {
            "constant": false,
            "inputs": [
                {
                    "name": "_pid",
                    "type": "uint256"
                },
                {
                    "name": "_buyer",
                    "type": "address"
                },
                {
                    "name": "_medicineName",
                    "type": "string"
                },
                {
                    "name": "_amount",
                    "type": "uint256"
                }
            ],
            "name": "sellMedicine",
            "outputs": [
                {
                    "name": "",
                    "type": "bool"
                }
            ],
            "payable": false,
            "stateMutability": "nonpayable",
            "type": "function"
        },
        {
            "constant": false,
            "inputs": [
                {
                    "name": "_pid",
                    "type": "uint256"
                },
                {
                    "name": "_delegator",
                    "type": "address"
                }
            ],
            "name": "setDelegator",
            "outputs": [],
            "payable": false,
            "stateMutability": "nonpayable",
            "type": "function"
        },
        {
            "constant": true,
            "inputs": [],
            "name": "getLatestCreatePrescriptionId",
            "outputs": [
                {
                    "name": "",
                    "type": "uint256"
                }
            ],
            "payable": false,
            "stateMutability": "view",
            "type": "function"
        },
        {
            "constant": true,
            "inputs": [],
            "name": "getPatientList",
            "outputs": [
                {
                    "name": "",
                    "type": "address[]"
                }
            ],
            "payable": false,
            "stateMutability": "view",
            "type": "function"
        },
        {
            "constant": true,
            "inputs": [
                {
                    "name": "id",
                    "type": "uint256"
                }
            ],
            "name": "getPrescription",
            "outputs": [
                {
                    "name": "",
                    "type": "string"
                },
                {
                    "name": "",
                    "type": "string"
                },
                {
                    "name": "",
                    "type": "string[]"
                },
                {
                    "name": "",
                    "type": "uint256[]"
                },
                {
                    "name": "",
                    "type": "uint256[]"
                }
            ],
            "payable": false,
            "stateMutability": "view",
            "type": "function"
        },
        {
            "constant": true,
            "inputs": [],
            "name": "getUserDetail",
            "outputs": [
                {
                    "name": "",
                    "type": "string"
                },
                {
                    "name": "",
                    "type": "uint8"
                }
            ],
            "payable": false,
            "stateMutability": "view",
            "type": "function"
        },
        {
            "constant": true,
            "inputs": [],
            "name": "userGetPrescription",
            "outputs": [
                {
                    "name": "",
                    "type": "uint256[]"
                }
            ],
            "payable": false,
            "stateMutability": "view",
            "type": "function"
        }
    ]
    
    var CoursetroContract = web3.eth.contract(abi);
    console.log(CoursetroContract);
    var contract = CoursetroContract.at(tokenAddr);
    return contract;
}


function getWalletAccount(index) {
    var selectedAccount = $('#account').find(":selected").val();
    return web3.eth.accounts[selectedAccount]
}

function getDefaultWalletAccount(index) {
    
    console.log(web3.eth.accounts);
    return web3.eth.accounts[index];
}

function getContract(index) {
    var walletAccount = getWalletAccount(index);
    console.log(walletAccount);
    var contract = getSmartContract(walletAccount);

    
    return contract;
}

function getDefaultContract() {
    var walletAccount = getDefaultWalletAccount(2);
    console.log(walletAccount);
    var contract = getSmartContract(walletAccount);

    
    return contract;
}

function initWeb3() {
    if (typeof web3 !== 'undefined') {
        web3 = new Web3(web3.currentProvider);
    } else {
        // set the provider you want from Web3.providers
        web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8546"));
    }
    console.log('web3!', web3)
}