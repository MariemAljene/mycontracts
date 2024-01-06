// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract CSPFeedbackModule {
    address public owner;
    
    mapping(address => mapping(address => uint256)) public cspFeedback;

    event FeedbackReceived(address indexed csp, address indexed customer, uint256 rating);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Permission denied");
        _;
    }

    function submitFeedback(address customer, uint256 rating) public {
        require(rating >= 1 && rating <= 5, "Invalid rating");

        cspFeedback[msg.sender][customer] = rating;

        emit FeedbackReceived(msg.sender, customer, rating);
    }
}
