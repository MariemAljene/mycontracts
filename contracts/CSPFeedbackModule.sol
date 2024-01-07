// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract CSPFeedbackModule {
    address public owner;
    
    mapping(address => mapping(address => uint256[])) public cspFeedback;

    mapping(address => uint256) public cspTrustScore;

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

        cspFeedback[msg.sender][customer].push(rating);

        emit FeedbackReceived(msg.sender, customer, rating);
    }

    function getAverageFeedback(address customer) public view returns (uint256) {
        uint256[] memory feedbacks = cspFeedback[msg.sender][customer];
        uint256 totalFeedback = 0;

        for (uint256 i = 0; i < feedbacks.length; i++) {
            totalFeedback += feedbacks[i];
        }

        if (feedbacks.length > 0) {
            return totalFeedback / feedbacks.length;
        } else {
            return 0; 
        }
    }

    function calculateTrustScore(address csp) internal view returns (uint256) {
        uint256 averageFeedback = getAverageFeedback(csp);
        
        uint256 tau = 1;
        uint256 m = cspFeedback[msg.sender][csp].length / (cspFeedback[msg.sender][csp].length + tau);

        uint256 trustScore = averageFeedback + (m * tau) / 2;
        return trustScore;
    }

    function updateTrustScore(address csp) public onlyOwner {
        uint256 newTrustScore = calculateTrustScore(csp);

        cspTrustScore[csp] = newTrustScore;
    }

    function getTrustScore(address csp) public view returns (uint256) {
        return cspTrustScore[csp];
    }
}
