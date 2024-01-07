// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract Service_SmartContract {
    
    mapping(address => uint256) public balances;

    event DepositDone(address indexed deposant, uint256 montant);

    function deposit() external payable {
        require(msg.value > 0, "amount should be > to 0");

        // Update correct balance
        balances[msg.sender] += msg.value;

        // Emit event
        emit DepositDone(msg.sender, msg.value);
    }

    function sendToContracts(address TS_Contract, address Clan_Contract, address walletCitizen) external payable {
        require(TS_Contract != address(0) && Clan_Contract != address(0) && walletCitizen != address(0), "Addresses should be different from original smartcontract address");
        require(balances[msg.sender] > 0, "Insufficient balance");

        uint256 amount = balances[msg.sender];

        // Define all amounts to be send
        uint256 TS_amount = (amount * 5) / 100; // 5% 
        uint256 Clan_amount = (amount * 5) / 100; // 5%
        uint256 Citizen_Salary = amount - TS_amount - Clan_amount; // left-over for the Citizen

        // First transaction to The Soci3ty
        (bool success_transac1, ) = payable(TS_Contract).call{value: TS_amount}("");
        require(success_transac1, "TS Transaction failed");

        // Second transaction to the Clan
        (bool success_transac2, ) = payable(Clan_Contract).call{value: Clan_amount}("");
        require(success_transac2, "Clan Transaction failed");

        // last transaction for the citizen
        payable(walletCitizen).transfer(Citizen_Salary);

        // Update the balance
        balances[msg.sender] = 0;
    }
}

contract TS_SmartContract{
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    // Fallback function to receive Ether
    receive() external payable {}
}
contract Clan_SmartContract{
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    // Fallback function to receive Ether
    receive() external payable {}
}
