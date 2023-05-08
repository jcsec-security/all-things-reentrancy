// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/03-xContract.sol";
import "../src/periphery_contracts/steth_token.sol";
import "../src/03-template_attacker.sol";


contract ProofOfConcept is Test {

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");       


    Vulnerable public victim;
    SyntheticETH public token;
    Attacker public actor_A;
    Attacker public actor_B;    

    // The setUp() function will be run before each test to set the initial scenario
    function setUp() public {
        // Declaring our contracts
        token = new SyntheticETH();
        victim = new Vulnerable(address(token));
        actor_A = new Attacker(address(victim), address(token));
        actor_B = new Attacker(address(victim), address(token));
        // Initial set up
        token.grantRole(MINTER_ROLE, address(victim));
        token.grantRole(BURNER_ROLE, address(victim));        
        actor_A.setSidekick(address(actor_B));
        actor_B.setSidekick(address(actor_A));
        // Labelling for test traces
        vm.label(address(token), "token_contract");         
        vm.label(address(victim), "victim_contract");         
        vm.label(address(actor_A), "attacker_A_contract");
        vm.label(address(actor_B), "attacker_B_contract");
        // Funding both parties
        vm.deal(address(actor_A), 1 ether); // It is not necessary to fund the attacker as you could just send eth along, but still
        vm.deal(address(actor_B), 1 ether);
        vm.deal(address(victim), 10 ether);
    }

    // Foundry tests should start with the word "test" to be recognized as such
    function test_exploit() public {
        console.log(unicode"\n   📚📚 All things reentrancy: cross-contract exploitation\n");
        console.log("--------------------------------------------------------");
        console.log(unicode"| => Victim's balance 🙂 %s 🙂", toEth(address(victim).balance));
        console.log(unicode"| => Attackers' balance 👀 %s 👀", toEth(address(actor_A).balance + address(actor_B).balance));
        console.log("--------------------------------------------------------"); 

        console.log(unicode"\n\t💥💥💥💥 EXPLOITING... 💥💥💥💥\n");
        
        actor_A.exploit();
        
        // Conditions to fullfill
        assertEq(address(victim).balance, 0);
        assertEq(address(actor_A).balance + address(actor_B).balance, 12 ether);

        console.log("--------------------------------------------------------"); 
        console.log(unicode"| => Victim's balance ☠  %s ☠", toEth(address(victim).balance));
        console.log(unicode"| => Attackers' balance 💯 %s 💯", toEth(address(actor_A).balance + address(actor_B).balance));
        console.log("--------------------------------------------------------");            
    }


    function toEth(uint256 _wei) internal pure returns (string memory) {
        string memory eth = vm.toString(_wei / 1 ether);
        string memory decs = vm.toString(_wei % 1 ether);

        string memory result = string.concat(
            string.concat(eth, "."),
            decs
        );

        return result;
    }      
}
