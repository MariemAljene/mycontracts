// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract CSPFeedbackModule {
    address public owner;

    struct FeedbackInfo {
        uint256 rating;
        uint256 latency;
    }

    struct CSPFeedbackEntry {
        address cspContract;
        uint256 rating;
        uint256[] latencies;
    }

    mapping(address => FeedbackInfo[]) public cspFeedback;
    uint256 public trustedValueOld;  // Initial trusted value

    event FeedbackReceived(address indexed csp, uint256 rating, uint256 latency);

    // Service-specific latency thresholds and weights
    mapping(bytes32 => uint256) public latencyThresholds;
    mapping(bytes32 => uint256) public serviceWeights;

    // Service-specific factors to adjust trust score based on latency impact
    mapping(bytes32 => int256) public serviceLatencyFactors;

    constructor() {
        owner = msg.sender;
        trustedValueOld = 0;  // Initialize trusted value

        // Set default latency thresholds, weights, and latency factors
        setDefaultSLA();
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Permission denied");
        _;
    }

    function setDefaultSLA() internal {
        // Set default latency thresholds and weights for each service type
        setSLA("Compute Instances", 200, 9999, 100, 1);  // Adjusted the weights to uint256 values, added latency factor
        setSLA("Storage Services", 10, 999, 40, -1);  // Added latency factor
        setSLA("Network Connectivity", 5, 1999, 40, 1);  // Added latency factor
        setSLA("Database Services", 100, 1999, 30, -1);  // Added latency factor
        setSLA("Application Hosting", 300, 999, 40, 1);  // Added latency factor
        setSLA("Content Delivery Network", 20, 999, 60, -1);  // Added latency factor
    }

    function setSLA(
        string memory serviceType,
        uint256 responseTimeThreshold,
        uint256 availabilityThreshold,
        uint256 incidentResolutionTimeThreshold,
        int256 latencyFactor
    ) internal {
        bytes32 serviceTypeHash = keccak256(abi.encodePacked(serviceType));
        latencyThresholds[serviceTypeHash] = responseTimeThreshold;
        serviceWeights[serviceTypeHash] = (availabilityThreshold * incidentResolutionTimeThreshold) / 100;
        serviceLatencyFactors[serviceTypeHash] = latencyFactor;
    }

    function submitFeedback(address cspContract, uint256 latency, string memory serviceType) public {
        bytes32 serviceTypeHash = keccak256(abi.encodePacked(serviceType));
        uint256 rating = calculateRating(latency, serviceTypeHash);
        trustedValueOld = calculateTrustScore(rating, latency, serviceTypeHash);

        emit FeedbackReceived(cspContract, rating, latency);

        cspFeedback[cspContract].push(FeedbackInfo(rating, latency));
    }

    function calculateRating(uint256 latency, bytes32 serviceType) internal view returns (uint256) {
        uint256 maxLatency = latencyThresholds[serviceType];

        if (latency <= maxLatency / 2) {
            return 3;
        } else if (latency <= maxLatency) {
            return 2;
        } else {
            return 1;
        }
    }

    function calculateTrustScore(uint256 feedback, uint256 latency, bytes32 serviceType) internal view returns (uint256) {
        if (latency == 0) {
            return 0;
        }

        uint256 weight = serviceWeights[serviceType];
        uint256 adjustedFeedback = (feedback * weight) / 100;

        int256 latencyFactor = serviceLatencyFactors[serviceType];

        return uint256(int256((trustedValueOld + adjustedFeedback + trustedValueOld) / 2) * latencyFactor);
    }

    function getTrust(address cspContract) public view returns (uint256) {
        FeedbackInfo[] memory feedback = cspFeedback[cspContract];
        
        if (feedback.length > 0) {
            FeedbackInfo memory latestFeedback = feedback[feedback.length - 1];
            return calculateRating(latestFeedback.latency, bytes32(0));
        } else {
            return 0;
        }
    }

    function getFeedbackByOwner(address cspContract) internal view onlyOwner returns (FeedbackInfo[] memory) {
        return cspFeedback[cspContract];
    }

    function getFeedbackDetails(address cspContract, uint256 index) internal view onlyOwner returns (uint256, uint256) {
        require(index < cspFeedback[cspContract].length, "Index out of bounds");
        FeedbackInfo memory feedback = cspFeedback[cspContract][index];
        return (feedback.rating, feedback.latency);
    }

    function calculateNewRating(uint256 latency, string memory serviceType) internal view returns (uint256) {
        bytes32 serviceTypeHash = keccak256(abi.encodePacked(serviceType));
        return calculateRating(latency, serviceTypeHash);
    }

    // Function to retrieve the ratings and latencies for a specific CSP contract
    function getRatingsAndLatencies(address cspContract) public view returns (CSPFeedbackEntry[] memory) {
        FeedbackInfo[] memory feedback = cspFeedback[cspContract];
        CSPFeedbackEntry[] memory entries = new CSPFeedbackEntry[](feedback.length);

        for (uint256 i = 0; i < feedback.length; i++) {
            uint256[] memory latencies = new uint256[](1);
            latencies[0] = feedback[i].latency;

            entries[i] = CSPFeedbackEntry({
                cspContract: cspContract,
                rating: feedback[i].rating,
                latencies: latencies
            });
        }

        return entries;
    }
}
