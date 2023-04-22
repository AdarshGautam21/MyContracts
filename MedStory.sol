// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract constomer{

    struct Patient{
        string name;
        address add;
        uint8 age;
        string fathersName;
    }

    uint256 public it = 1;

    mapping(uint256=>Patien
    t) public patientMapping;

    function setPatient(string memory _name, string memory _fathersName, uint8 _age) public {
        Patient memory pat;
        pat.name = _name;
        pat.fathersName = _fathersName;
        pat.age = _age;

        patientMapping[it++] = pat;
    }


    function getPatient(uint8 id) view public returns(string memory, address, uint8, string memory) {
        Patient memory pat = patientMapping[id]; 
        return (pat.name,pat.add,pat.age,pat.fathersName);
    }
}