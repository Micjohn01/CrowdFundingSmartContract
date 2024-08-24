// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract CrowdFunding {
    // A struct to save the properties of a campaign
    struct CampaignStructure {
        string title;
        string description;
        address payable benefactor;
        uint goal;
        uint deadline;
        uint amountRaised;
        bool campaignEnded;
    }

    address public owner;
    uint public campaignCount = 0;
    mapping(uint => CampaignStructure) public campaigns;

    event CampaignCreated(uint campaignId, string title, string description, address benefactor, uint goal, uint deadline);
    event DonationReceived(uint campaignId, address donor, uint amount);
    event CampaignHasEnded(uint campaignId, uint totalAmountRaised, bool goalReached);

    modifier onlyOwner() {
        require(msg.sender == owner, "Owner access only");
        _;
    }

    modifier campaignActive(uint campaignId) {
        require(block.timestamp < campaigns[campaignId].deadline, "Ended");
        require(!campaigns[campaignId].campaignEnded, "Campaign has ended already");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // To create a campaign function
    function createCampaign(
        string memory _title, string memory _description, address payable _campaignBenefactor,
        uint _goal, uint _durationInSeconds) public {
        require(_goal > 0, "goal should be greater than zero");

        campaignCount = campaignCount + 1;
        uint deadline = block.timestamp + _durationInSeconds;

        campaigns[campaignCount] = CampaignStructure({
            title: _title,
            description: _description,
            benefactor: _campaignBenefactor,
            goal: _goal,
            deadline: deadline,
            amountRaised: 0,
            campaignEnded: false
        });

        emit CampaignCreated(campaignCount, _title, _description, _campaignBenefactor, _goal, deadline);
    }

    // Function to donate to campaign of your choice
    function donateToCampaign(uint campaignId) public payable campaignActive(campaignId) {
        CampaignStructure memory campaign = campaigns[campaignId];
        require(msg.value > 0, "You can not donate zero amount");

        // Conditional: Check if the goal has been reached before accepting more donations
        if (campaign.amountRaised + msg.value > campaign.goal) {
            uint refundAmount = (campaign.amountRaised + msg.value) - campaign.goal;
            campaign.amountRaised = campaign.goal;
            campaign.campaignEnded = true;
            payable(msg.sender).transfer(refundAmount);  // Refund the excess amount
        } else {
            campaign.amountRaised += msg.value;
        }

        emit DonationReceived(campaignId, msg.sender, msg.value);
    }

    // Function end campaign and transfer funds
    function endCampaign(uint campaignId) public campaignActive(campaignId) {
        CampaignStructure storage campaign = campaigns[campaignId];
        require(block.timestamp >= campaign.deadline, "You can still donate");

        campaign.campaignEnded = true;

        // To check if the goal was reached
        bool campaignGoalReached = campaign.amountRaised >= campaign.goal;

        if (campaignGoalReached) {
            // if the goal is reached, the fund should be transferred
            campaign.benefactor.transfer(campaign.amountRaised);
        } else {
            // if the goal was not reached, the amount of fund raised should still be transferred
            campaign.benefactor.transfer(campaign.amountRaised);
        }

        emit CampaignHasEnded(campaignId, campaign.amountRaised, campaignGoalReached);
    }

    function withdrawLeftoverFunds() public onlyOwner {
        uint balance = address(this).balance;
        require(balance > 0, "Sorry! No fund is available");
        payable(owner).transfer(balance);
    }
}
