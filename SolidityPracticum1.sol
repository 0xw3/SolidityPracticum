// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract SolidityPracticum1 {
    uint256 varUint256 = 10;
    address public owner = 0xEd8f4682da7366433BB2966b04F0feEac7e668c3;
    bool varBool = false;

    uint256 constant constUint256 = 10;

    uint256[] arrDyn;

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint)) nestedMapping;

    // Mapping with Struct
    struct User {
        bool sybil;
        uint256 amount;
    }
    mapping(address => User) user;

    // Struct with struct
    struct Payment {
        User user;
        uint256 amount;
    }

    // array of struct
    User[] users;

    // Modifiers
    modifier nonZeroAddress(address _address) {
        require(_address != address(0), "Zero address!");
        _;
    }

    modifier onlyOwner {
        require(owner == msg.sender, "Not owner!");
        _;
    }

    // Change of contract owner
    function ownerChange(address _newOwner) nonZeroAddress(_newOwner) onlyOwner public{
        owner = _newOwner;
    }

    // Immutable
    uint256 immutable immUint256;

    constructor (uint256 _immUint256) {
        immUint256 = _immUint256;
        owner = msg.sender;
    }

    // Dynamic arrays
    uint256[] public prices;

    function addToArr(uint256 _value) public {
        prices.push(_value);
    }
    
    function removeFromArr() public returns (uint256) {
        require(prices.length > 0,"Array is empty!");
        uint256 price = prices[prices.length-1];
        prices.pop();
        return price;
    }

    // Nested mapping
    mapping (address => mapping (address => uint256)) tokenBalances;
    
    function addBalance(address _user, address _token, uint256 _amount) public {
        tokenBalances[_user][_token] += _amount;
    }

    function removeBalance(address _user, address _token) public {
        delete  tokenBalances[_user][_token];
    }

    function getBalance(address _user, address _token) public view returns(uint256){
        return tokenBalances[_user][_token];
    }

    // Mapping of struct
    enum ReasonSybil {
        IP,
        SameGasSource,
        Pattern
    }
    struct Sybil {
        uint256 timestamp;
        ReasonSybil reason;
    }

    mapping(address => Sybil) sybils;

    function addSybil(address _user, ReasonSybil _reason) public {
        sybils[_user] = Sybil(block.timestamp, _reason);
    }

    // Array of struct
    struct SybilArr {
        address user;
        uint256 timestamp;
        ReasonSybil reason;
    }
    
    SybilArr[] sybilsArr;

    function addSybilToArr(address _user, ReasonSybil _reason) public {
        sybilsArr.push(SybilArr(_user, block.timestamp, _reason));
    }

    // Ethers log
    mapping (address => uint256) balance;
    function pay() public payable {
        balance[msg.sender] += msg.value;
    }
    
}