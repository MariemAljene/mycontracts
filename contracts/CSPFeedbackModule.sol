// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract CSPFeedbackModule {
    address public owner;
    
    struct Feedback {
        uint256 rating;
        uint256 timestamp;
    }

    mapping(address => mapping(address => Feedback[])) public cspFeedback;
    mapping(address => uint256) public cspTrustScore;
    uint256 public Lmax;  // Maximum acceptable latency

    event FeedbackReceived(address indexed csp, address indexed customer, uint256 rating);


    constructor(uint256 _Lmax) {
        owner = msg.sender;
        Lmax = _Lmax;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Permission denied");
        _;
    }

    function submitFeedback(address customer, uint256 rating) public {
        // Automatically calculate latency
        Feedback memory newFeedback = Feedback(rating, block.timestamp);
        cspFeedback[msg.sender][customer].push(newFeedback);
        uint256 latency = block.timestamp - newFeedback.timestamp;

        // Calculate feedback based on Lt / Lmax
        uint256 rate = calculateFeedback(latency);

        emit FeedbackReceived(msg.sender, customer, rate);

        // Automatically update trust score after feedback submission
        updateTrustScore(customer);
    }

    function getWeightedAverageFeedback(address customer) public view returns (uint256) {
        Feedback[] memory feedbacks = cspFeedback[msg.sender][customer];
        uint256 totalWeightedFeedback = 0;
        uint256 totalWeight = 0;

        for (uint256 i = 0; i < feedbacks.length; i++) {
            uint256 weight = calculateWeight(feedbacks[i].timestamp);
            totalWeightedFeedback += feedbacks[i].rating * weight;
            totalWeight += weight;
        }

        if (totalWeight > 0) {
            return totalWeightedFeedback / totalWeight;
        } else {
            return 0;
        }
    }

    function calculateWeight(uint256 timestamp) internal view returns (uint256) {
        // Customize your weighting logic here
        uint256 timeDifference = block.timestamp - timestamp;
        
        // Example: Linear decay where more recent feedback has higher weight
        return timeDifference <= 1 days ? 3 : 1;  // Adjust the weights based on your requirements
    }

    function calculateFeedback(uint256 latency) internal view returns (uint256) {
        // Calculate feedback based on Lt / Lmax
        if (latency > Lmax) {
            return 0;
        }

        return (latency * 100) / Lmax; // Assuming Lmax is not zero to avoid division by zero
    }

    function calculateTrustScore(address csp) internal view returns (uint256) {
        uint256 averageFeedback = getWeightedAverageFeedback(csp);
        
        uint256 tau = 1;
        uint256 m = cspFeedback[msg.sender][csp].length / (cspFeedback[msg.sender][csp].length + tau);

        uint256 trustScore = averageFeedback + (m * tau) / 2;
        return trustScore;
    }

    function updateTrustScore(address csp) internal {
        uint256 newTrustScore = calculateTrustScore(csp);

        cspTrustScore[csp] = newTrustScore;
    }

    function getTrustScore(address csp) public view returns (uint256) {
        return cspTrustScore[csp];
    }
}
