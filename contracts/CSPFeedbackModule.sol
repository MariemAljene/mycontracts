// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract CSPFeedbackModule {
    address public owner;
    
    // Mapping to store a list of feedbacks for each customer and CSP pair
    mapping(address => mapping(address => uint256[])) public cspFeedback;

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

        // Store the feedback in the array
        cspFeedback[msg.sender][customer].push(rating);

        emit FeedbackReceived(msg.sender, customer, rating);
    }

    // Function to calculate the average of feedbacks
    function getAverageFeedback(address customer) public view returns (uint256) {
        uint256[] memory feedbacks = cspFeedback[msg.sender][customer];
        uint256 totalFeedback = 0;

        // Calculate the sum of feedbacks
        for (uint256 i = 0; i < feedbacks.length; i++) {
            totalFeedback += feedbacks[i];
        }

        // Calculate the average
        if (feedbacks.length > 0) {
            return totalFeedback / feedbacks.length;
        } else {
            return 0; // Return 0 if there are no feedbacks
        }
    }
}
