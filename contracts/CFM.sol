// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract CFM {
    address public owner;

    mapping(address => uint256) public cspTrustScore;
    uint256 public trustedValueOld;  // Initial trusted value

    event FeedbackReceived(address indexed csp, uint256 rating);

    constructor() public {
        owner = msg.sender;
        trustedValueOld = 0;  // Initialize trusted value
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Permission denied");
        _;
    }

    // Update the function to include latency-based SLA
    function submitFeedback(address cspContract, uint256 rating, uint256 latency) public onlyOwner {
        require(rating >= 1 && rating <= 5, "Invalid feedback rating"); // Assuming feedback is in the range 1 to 5

        // Check latency condition: If latency is below a threshold, give a score near 1; otherwise, near 0
        uint256 latencyScore = (latency < MAX_LATENCY_THRESHOLD) ? 1 : 0;

        // Update trust score based on the new feedback and latency condition
        uint256 newTrustScore = calculateTrustScore(rating, latencyScore);

        // Update trusted value for future calculations
        trustedValueOld = newTrustScore;

        emit FeedbackReceived(cspContract, rating);

        // Update trust score in the mapping for the specified CSP contract
        cspTrustScore[cspContract] = newTrustScore;
    }

    // Update the function to include latency-based SLA
    function calculateTrustScore(uint256 feedback, uint256 latencyScore) internal view returns (uint256) {
        // Simple calculation: (oldTrustValue + newFeedback + latencyScore) / 3
        return (trustedValueOld + feedback + latencyScore) / 3;
    }

    function getTrustScore(address cspContract) public view returns (uint256) {
        return cspTrustScore[cspContract];
    }

    // Define the maximum allowed latency threshold
    uint256 constant MAX_LATENCY_THRESHOLD = 100; // Adjust the value based on your requirements
}