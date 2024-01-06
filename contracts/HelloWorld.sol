// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract mycontract {
   string public message ;  
    constructor () //deployed everytime we run the app 
    { 
        message= "HelloWorld" ; 
 
 
    }

 function getMessage() public view returns (string memory) // memory temporary 
 { 
return message ; 
 }
}