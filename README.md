# All things reentrancy!

This repo contains all the details to follow along with the "All things reentrancy" workshop/talk. 


:star: The target audience includes both **smart contract developers** looking to improve their secure coding practices and **beginner auditors/security people** looking to get an overview on how to **identify basic examples** of the wider family of reentrancy bugs and **crafting your first exploit/proof of concept** for each of them.


:point_right: If you are already a little bit ahead on your Solidity security journey, this content may be too basic for you :smiley:


## Foundry setup

All the exploitation tests aka Proof of Concept (PoC) will be done using foundry. It does not matter if you are not familiar with the tool as we will use just a fraction of its capabilities for testing basic scenarios and the tests cases, written in solidity,  are provided as part of the exercise so participants can just focus on the attacker contracts.


First and foremost, install Foundry following [these details](https://github.com/foundry-rs/foundry#installation). After the successful installation, please run the following to check that everything is in place:
```sh
foundryup # look for updates
forge init myTestProject # Create a foundry template project
cd myTestProject 
forge test # run the current tests
```

If the above tests were successful, your Foundry instance is ready for the workshop :heavy_check_mark:


## Workshop

First and foremost, clone this repo, cd into the dir and install the following dependencies:
```sh
forge install openzeppelin/openzeppelin-contracts # downloads the latest version of the OZ contracts under the lib directory
forge remappings # List current remappings, should already include the OZ ones we just download at the bottom
```

This is enough for foundry to recognize the mappings and successfully compile but let’s add one more thing so VS code stops showing the import error
```sh
forge remappings > remappings.txt
```

You will find one vulnerable contract for each type of reentrancy bug currently covered. Each of them will have a template attacker contract named `0X-template_attacker.sol` ready for you to craft your own attacking contract. Finally, under `test/0X-poc.sol` you will find a test/PoC ready to fire your attacker contract. Proposed solutions can be found in `src/solutions/`... but not yet :innocent:

- [Basic reentrancy](/src/00-basic.sol/)
- [Token-callback reentrancy](/src/01-tokenCallback.sol/)
- [Cross-function reentrancy](/src/02-xFunction.sol/)
- [Basic reentrancy with a twist](/src/02-basic_b.sol/)
- [Cross-contract reentrancy](/src/03-xContract.sol/)
- [Read only reentrancy](/src/04-readOnly.sol/)


### 00 Basic reentrancy

This is the most basic type of reentrancy, the victim exposes the following functions:
- `function withdrawAll() external`
- `function withdrawSome() external`
- `function deposit() external payable`
- `function userBalance (address user) public view returns (uint256)`


Modify `src/00-template_sttacker.sol` to successfully pass the test found in `test/00-poc.sol` to proof the success of your attack. Play around with both withdraw functions to understand why one of them is directly exploitable and not the other! Are you able to showcase an exploit scenario for both cases?


:computer: Use the following line to run the test and check the success of your proof of concept:
```sh
forge test --match-path test/00-poc.sol -vvv # If you add a fourth v (-vvvv) you will see the traces for successful tests too, very interesting!
```


### 01 Token callback reentrancy

Here we have a basic ERC-721 implementation that exposes just one relevant function:
- `function mint() external payable`


Modify `src/01-template_attacker.sol` to successfully pass the test found in `test/01-poc.sol` to proof the success of your attack. 

:computer: Use the following line to run the test and check the success of your proof of concept:
```sh
forge test --match-path test/01-poc.sol -vvv # If you add a fourth v (-vvvv) you will see the traces for successful tests too, very interesting!
```


### 02 Cross function reentrancy

The target contract is very similar to the 00 example, however, the vulnerable function is now marked as `nonReentrant`. A new feature to move funds has also been added!
- `function deposit() external payable`
- `function withdraw() external nonReentrant()`
- `function transferTo(address _recipient, uint _amount) external`

Modify `src/02-template_attacker.sol` to successfully pass the test found in `test/02-poc.sol` to proof the success of your attack. 

:computer: Use the following line to run the test and check the success of your proof of concept:
```sh
forge test --match-path test/02-poc.sol -vvv # If you add a fourth v (-vvvv) you will see the traces for successful tests too, very interesting!
```


### 02_b Basic reentrancy with a twist

This example is a simplified implementation of a tokenized vault, which increases the user shares when eth is locked in the contract. It exposes the following functions:
- `function deposit() external payable`
- `function withdraw(uint256 amount) external`
- `function stake(uint256 amount) external returns (uint256)`
- `function unstake(uint256 amount) external returns (uint256)`


Modify `src/02-template_attacker_b.sol` to successfully pass the test found in `test/02-poc_b.sol` to proof the success of your attack. 

:computer: Use the following line to run the test and check the success of your proof of concept:
```sh
forge test --match-path test/02-poc_b.sol -vvv # If you add a fourth v (-vvvv) you will see the traces for successful tests too, very interesting!
```


### 03 Cross contract reentrancy

The idea is similar to the previous one, however, instead of book-keeping each deposited eth a stEth ERC-20 token is minted. Also... every function is `nonReentrant`.
- `function stake() external payable nonReentrant()`
- `function unstake() external nonReentrant()`


The auxiliary token contract includes a `burnAll()` function that allows the burned to burn the whole balance of a given user.


Modify `src/03-template_attacker.sol` to successfully pass the test found in `test/03-poc.sol` to proof the success of your attack. 

:computer: Use the following line to run the test and check the success of your proof of concept:
```sh
forge test --match-path test/03-poc.sol -vvv # If you add a fourth v (-vvvv) you will see the traces for successful tests too, very interesting!
```


### 04 Read only reentrancy

The last one depicts a Liquidity pool ETH-stETH that is used as data source by a Lending protocol (check `src/periphery/reader_lender.sol`). Every function is `nonReentrant` and have external interactions in the last place.
- `function addLiquidity(uint256 stEth_amount, uint256 eth_amount) external payable nonReentrant() returns (uint256)`
- `function removeLiquidity(uint256 lp_amount) external nonReentrant() returns (uint256, uint256)`
- `function getSpotPriceStEth(uint256 amount) public view returns (uint256)`
- `function getSpotPriceEth(uint256 amount) public view returns (uint256)`


Modify `src/04-template_attacker.sol` to successfully pass the test found in `test/04-poc.sol` to proof the success of your attack. 

:computer: Use the following line to run the test and check the success of your proof of concept:
```sh
forge test --match-path test/04-poc.sol -vvv # If you add a fourth v (-vvvv) you will see the traces for successful tests too, very interesting!
```
