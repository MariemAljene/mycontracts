// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "@thirdweb-dev/contracts/extension/ContractMetadata.sol";

contract CustomerFeedbackModule {
    address public owner;
    
    mapping(address => mapping(address => uint256)) public customerFeedback;

    event FeedbackReceived(address indexed customer, address indexed csp, uint256 rating);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Permission denied");
        _;
    }

    function submitFeedback(address csp, uint256 rating) public {
        require(rating >= 1 && rating <= 5, "Invalid rating");

        customerFeedback[msg.sender][csp] = rating;

        emit FeedbackReceived(msg.sender, csp, rating);
    }
}
