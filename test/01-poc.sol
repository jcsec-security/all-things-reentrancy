// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/01-tokenCallback.sol";
import "../src/01-template_attacker.sol";

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
    }

    // Foundry tests should start with the word "test" to be recognized as such
    function test_exploit() public {
        console.log(unicode"\n   📚📚 All things reentrancy: callback-based exploitation\n");
        console.log("--------------------------------------------------------");
        console.log(unicode"| => Victim's supply 🙂 %s 🙂", victim.totalSupply());
        console.log(unicode"| => Attacker's balance 👀 %s 👀", victim.balanceOf(address(attacker)));
        console.log("--------------------------------------------------------"); 

        console.log(unicode"\n\t💥💥💥💥 EXPLOITING... 💥💥💥💥\n");  

        attacker.exploit();

        // Conditions to fullfill
        assertEq(victim.balanceOf(address(attacker)), 10);

        console.log("--------------------------------------------------------"); 
        console.log(unicode"| => Victim's supply ☠  %s ☠", victim.totalSupply());
        console.log(unicode"| => Attacker's balance 💯 %s 💯", victim.balanceOf(address(attacker)));
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
