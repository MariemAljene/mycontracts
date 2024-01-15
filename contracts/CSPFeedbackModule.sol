// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract CSPFeedbackModule {
    address public owner;

    mapping(address => uint256) public cspTrustScore;
    uint256 public trustedValueOld;  // Initial trusted value

    event FeedbackReceived(address indexed csp, uint256 rating);

    constructor() {
        owner = msg.sender;
        trustedValueOld = 0;  // Initialize trusted value
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Permission denied");
        _;
    }

    function submitFeedback(address cspContract, uint256 rating) public onlyOwner {
        require(rating >= 1 && rating <= 5, "Invalid feedback rating"); // Assuming feedback is in the range 1 to 5

        // Update trust score based on the new feedback
        uint256 newTrustScore = calculateTrustScore(rating);

        // Update trusted value for future calculations
        trustedValueOld = newTrustScore;

        emit FeedbackReceived(cspContract, rating);

        // Update trust score in the mapping for the specified CSP contract
        cspTrustScore[cspContract] = newTrustScore;
    }

    function calculateTrustScore(uint256 feedback) internal view returns (uint256) {
        // Simple calculation: (oldTrustValue + newFeedback) / 2
        return (trustedValueOld + feedback) / 2;
    }

    function getTrustScore(address cspContract) public view returns (uint256) {
        return cspTrustScore[cspContract];
    }
}
