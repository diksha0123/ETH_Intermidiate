// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract WaterBilling {
    address public owner;
    uint public free_Units = 100; 
    uint public ratePer_Unit;

    mapping(address => uint) public usage; 
    mapping(address => uint) public bills; 

    event BillPaid(address indexed user, uint amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    constructor(uint _ratePer_Unit) {
        require(_ratePer_Unit > 0, "Rate per unit must be greater than zero");
        owner = msg.sender;
        ratePer_Unit = _ratePer_Unit;
    }

    function recordUsage(address user, uint units) external onlyOwner {
        require(units > 0, "Usage must be greater than zero");

        usage[user] += units;
    }

    function calculateBill(address user) external onlyOwner returns (uint) {
        uint totalUnits = usage[user];
        require(totalUnits > 0, "No usage recorded for this user");

        if (totalUnits <= free_Units) {
            bills[user] = 0;
        } else {
            uint chargeableUnits = totalUnits - free_Units;
            bills[user] = chargeableUnits * ratePer_Unit;
        }

        assert(bills[user] >= 0); 
        return bills[user];
    }

    function payBill() external payable {
        uint billAmount = bills[msg.sender];
        require(billAmount > 0, "No bill due");
        require(msg.value == billAmount, "Incorrect bill amount");

        bills[msg.sender] = 0;
        emit BillPaid(msg.sender, msg.value);
    }

    function withdraw() external onlyOwner {
        uint balance = address(this).balance;
        require(balance > 0, "No funds available for withdrawal");
        payable(owner).transfer(balance);
    }

    function setRatePerUnit(uint _ratePerUnit) external onlyOwner {
        require(_ratePerUnit > 0, "Rate per unit must be greater than zero");
        ratePer_Unit = _ratePerUnit;
    }

   
    function setFreeUnits(uint _freeUnits) external onlyOwner {
        require(_freeUnits >= 0, "Free units must be non-negative");
        free_Units = _freeUnits;
    }

    receive() external payable {
        revert("WaterBilling contract does not accept Ether directly");
    }
}