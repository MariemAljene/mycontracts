// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract CSPFeedbackModule {
    address public owner;
    
    // Mapping to store a list of feedbacks for each customer and CSP pair
    mapping(address => mapping(address => uint256[])) public cspFeedback;

    // Mapping to store the trust score for each CSP
    mapping(address => uint256) public cspTrustScore;

    // Event to emit when feedback is received
    event FeedbackReceived(address indexed csp, address indexed customer, uint256 rating);

    constructor() {
        owner = msg.sender;
    }

    // Modifier to restrict access to the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Permission denied");
        _;
    }

    // Function to submit feedback
    function submitFeedback(address customer, uint256 rating) public {
        require(rating >= 1 && rating <= 5, "Invalid rating");

        // Store the feedback in the array
        cspFeedback[msg.sender][customer].push(rating);

        // Emit the feedback received event
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

    // Function to calculate the trust score for a CSP
    function calculateTrustScore(address csp) internal view returns (uint256) {
        uint256 averageFeedback = getAverageFeedback(csp);
        
        // Formula for trust calculation
        uint256 tau = 1;
        uint256 m = cspFeedback[msg.sender][csp].length / (cspFeedback[msg.sender][csp].length + tau);

        uint256 trustScore = averageFeedback + (m * tau) / 2;
        return trustScore;
    }

    // Function to update the trust score for a CSP
    function updateTrustScore(address csp) public onlyOwner {
        uint256 newTrustScore = calculateTrustScore(csp);

        // Update the trust score
        cspTrustScore[csp] = newTrustScore;
    }

    // Function to get the trust score for a CSP
    function getTrustScore(address csp) public view returns (uint256) {
        return cspTrustScore[csp];
    }
}
