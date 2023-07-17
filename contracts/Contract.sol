// SPDX-License-Identifier: MIT 
pragma solidity >=0.5.0 <0.9.0;

contract Agify {
    struct User {
        string name;
        string sex;
        string time;
        string hname;
        string id;
        string fname;
        string mname;
        string dob;
        string place;
    }

    struct pendingRequest{
        string hname;
        string img;
        string hid;
        address haddress;
    }

    address public owner;
    pendingRequest[] pendingRequests;
    //address[] public authorizedAddress;     // who can enter data
    //string memory[] public hospitalId;               // list of unique hospital ids

    mapping(string => User) public users;  //store user data against their Id
    mapping(string => bool) public userStatus; // check status whether data exist for an user
    mapping(string => bool) public hospitalIdStatus;    // check status whether account exist for a hospital
    mapping(address => bool) public authorizedAddress;  // who can enter data

    constructor() {
        owner=msg.sender;
        // pendingRequests = new pendingRequest[](0);
    }

// to check if DOB already exist for a particular id
    modifier dobNotSet(string memory id) {
        require(!userStatus[id], "Data has already been set for this ID");
        _;
    }
// to check that the authorized address can only store data
    modifier onlyAuthorized(address _add) {
        require(authorizedAddress[_add]==true, "Only authorized address can store DOB");
        _;
    }

    modifier isOwner(address _add) {
        require(_add==owner, "Only owner can enter hospitalId");
        _;
    }

    function checkRegistration(string memory bid) public view returns(bool) {
        return userStatus[bid];
    }

    function allowHospital(string memory _hospitalId, address _authorizedAddress, address _oaddress) public isOwner(_oaddress) {
        if(hospitalIdStatus[_hospitalId] == false){
            hospitalIdStatus[_hospitalId]=true;
            authorizedAddress[_authorizedAddress]=true;
        }
        deletePendingRequest(_hospitalId,_authorizedAddress,_oaddress);
    }

    function enterData(string memory _name,string memory _sex,string memory _time,string memory _hname,string memory _id, string memory _fname, string memory _mname, string memory _dob, string memory _place, address _add) public onlyAuthorized(_add) dobNotSet(_id) {
        users[_id] = User(_name,_sex,_time,_hname,_id, _fname, _mname, _dob, _place);
        userStatus[_id]=true;
    }

    function getData(string memory _id) public view returns (User memory) {
        return users[_id];
    }

    function checkOwner(address oid) public view returns(bool) {
        return owner==oid;
    }

    function checkHospital(address hid) public view returns(bool) {
        return authorizedAddress[hid];
    }

    function addHospitalRequest(string memory _hname,string memory _img,string memory _hid,address _haddress) public {
        require(hospitalIdStatus[_hid]==false && authorizedAddress[_haddress]==false,"Hospital already has access");
        pendingRequests.push(pendingRequest(_hname,_img,_hid,_haddress)); 
    }

    function getPendingRequest(address _oaddress) public view returns (pendingRequest[] memory) {
        require(_oaddress==owner, "Only owner can enter hospitalId");
        return pendingRequests;
    }

    function deletePendingRequest(string memory _hid, address _haddress, address _oaddress) public isOwner(_oaddress) {
        for (uint256 i = 0; i < pendingRequests.length; i++) {
            if ((keccak256(abi.encodePacked(pendingRequests[i].hid)) == keccak256(abi.encodePacked(_hid))) && pendingRequests[i].haddress==_haddress) {
                // Move the last element to the current index
                pendingRequests[i] = pendingRequests[pendingRequests.length - 1];
                // Remove the last element (duplicate)
                pendingRequests.pop();
                return;
            }
        }
    }
}