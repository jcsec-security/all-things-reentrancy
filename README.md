# All Things Reentrancy!

This repo contains all the details to follow along with the "All Things Reentrancy" workshop/talk. Check the YouTube recording of the live session with the Calyptus community [here](https://www.youtube.com/watch?v=vR98s7W-aX4).


:star: The target audience includes both **smart contract developers** looking to improve their secure coding practices and **beginner auditors/security people** looking to learn how to **identify basic examples** of the wider family of reentrancy bugs and **craft their first exploit/proof of concept** for each of them.


:point_right: If you are already a little bit ahead on your Solidity security journey, this content may be too basic for you :smiley:


## Foundry setup

All exploitation tests, or proofs of concept (PoCs), use Foundry. It does not matter if you are not familiar with the tool: we use just a fraction of its capabilities, and the Solidity test cases are provided so participants can focus on the attacker contracts.


You need Git and [Foundry](https://getfoundry.sh/introduction/installation/) installed and available in your shell (use Git Bash or WSL on Windows). This setup is verified with Foundry v1.8.7, also used by CI. To select that version with `foundryup`:

```sh
foundryup --install v1.8.7
forge --version
```

The project pins Solidity **0.8.20** and the **Shanghai** EVM target in `foundry.toml`. Forge downloads the compiler on the first build; no separate Solidity installation is needed. Initial setup requires internet access.

Dependencies are tracked as Git submodules at these exact commits:

| Dependency | Release | Commit |
| --- | --- | --- |
| OpenZeppelin Contracts | [v5.0.2](https://github.com/OpenZeppelin/openzeppelin-contracts/releases/tag/v5.0.2) | `dbb6104ce834628e473d2173bbc9d47f81a9eec3` |
| Forge Standard Library | [v1.9.7](https://github.com/foundry-rs/forge-std/releases/tag/v1.9.7) | `77041d2ce690e692d6e03cc812b57d1ddaa4d505` |

The existing ERC-721 overrides and `utils/ReentrancyGuard.sol` imports use OpenZeppelin 5 APIs, which require Solidity 0.8.20 or later. These pins preserve that API without migrating the exercises.


## Workshop

Clone the repository with its pinned dependencies, then compile from the repository root:

```sh
git clone --recurse-submodules https://github.com/jcsec-security/all-things-reentrancy.git
cd all-things-reentrancy
forge build
```

If you already cloned without submodules, initialize them before building:

```sh
git submodule update --init --recursive
forge build
```

Use the recorded submodule commits rather than installing the latest library releases. Import remappings are already configured in `foundry.toml`. If your editor needs a separate remappings file, you can optionally generate one:

```sh
forge remappings > remappings.txt
```

You will find one vulnerable contract for each type of reentrancy bug covered. Each has a template attacker contract under `src/`, named `<exercise>-template_attacker.sol`, ready for you to craft your own attack. Under `test/<exercise>-poc.sol` you will find a test/PoC ready to run your attacker contract. Solutions are not currently provided :innocent:

Run an individual exercise with, for example:

```sh
forge test --match-path test/00-poc.sol -vvv
```

**The attacker templates are intentionally incomplete.** The project should compile as provided, but all seven exploitation tests initially fail their success assertions. This is expected: implement the corresponding attacker template to satisfy the existing assertions. Compilation errors or failures in `setUp()` are not expected. Run `forge test -vvv` to see all exercises; use `-vvvv` to include traces for successful tests too. CI checks compilation only.

Compiler and lint warnings about incomplete templates or intentionally vulnerable code may appear; a successful build does not require removing those warnings.

- [00 Basic reentrancy](src/00-basic.sol)
- [01 Token-callback reentrancy](src/01-tokenCallback.sol)
- [02 Cross-function reentrancy](src/02-xFunction.sol)
- [03 Cross-contract reentrancy](src/03-xContract.sol)
- [04_1 Basic reentrancy with subtraction](src/04_1-subtraction.sol)
- [04_2 Basic reentrancy with subtraction, more complex](src/04_2-subtraction.sol)
- [05 Read-only reentrancy](src/05-readOnly.sol)


### 00 Basic reentrancy

This is the most basic type of reentrancy. The victim exposes the following functions:

- `function withdrawAll() external`
- `function withdrawSome(uint256 amount) external`
- `function deposit() external payable`
- `function userBalance(address _user) public view returns (uint256)`

Modify `src/00-template_attacker.sol` to successfully pass the test found in `test/00-poc.sol` to prove the success of your attack. Play around with both withdraw functions to understand why one of them is directly exploitable and not the other! Are you able to showcase an exploit scenario for both cases?

:computer: Use the following line to run the test and check the success of your proof of concept:
```sh
forge test --match-path test/00-poc.sol -vvv # If you add a fourth v (-vvvv) you will see the traces for successful tests too, very interesting!
```


### 01 Token-callback reentrancy

Here we have a basic ERC-721 implementation that exposes just one relevant function:

- `function mint() external payable`

Modify `src/01-template_attacker.sol` to successfully pass the test found in `test/01-poc.sol` to prove the success of your attack. 

:computer: Use the following line to run the test and check the success of your proof of concept:
```sh
forge test --match-path test/01-poc.sol -vvv # If you add a fourth v (-vvvv) you will see the traces for successful tests too, very interesting!
```


### 02 Cross-function reentrancy

The target contract is very similar to example `00`, however, the vulnerable function is now marked as `nonReentrant`. A new feature to move funds has also been added!

- `function deposit() external payable`
- `function withdraw() external nonReentrant()`
- `function transferToInternally(address _recipient, uint _amount) external`

Modify `src/02-template_attacker.sol` to successfully pass the test found in `test/02-poc.sol` to prove the success of your attack. 

:computer: Use the following line to run the test and check the success of your proof of concept:
```sh
forge test --match-path test/02-poc.sol -vvv # If you add a fourth v (-vvvv) you will see the traces for successful tests too, very interesting!
```


### 03 Cross-contract reentrancy

The idea is similar to the previous one, but instead of bookkeeping each deposited ETH, a synthetic ETH ERC-20 token is minted. Both `deposit()` and `withdraw()` are `nonReentrant`.

- `function deposit() external payable nonReentrant()`
- `function withdraw() external nonReentrant()`


The auxiliary token contract includes a `burnAll(address from)` function that allows an account with `BURNER_ROLE` to burn a user's entire balance.


Modify `src/03-template_attacker.sol` to successfully pass the test found in `test/03-poc.sol` to prove the success of your attack. 

:computer: Use the following line to run the test and check the success of your proof of concept:
```sh
forge test --match-path test/03-poc.sol -vvv # If you add a fourth v (-vvvv) you will see the traces for successful tests too, very interesting!
```


### 04_1 Basic reentrancy with subtraction

This example is a simplified vault. A user can claim the title of King when their recorded balance exceeds the amount recorded for the current King. Its main functions are:

- `function deposit() external payable`
- `function withdraw(uint256 amount) external`
- `function claimKing() external returns (bool)`

Modify `src/04_1-template_attacker.sol` to successfully pass the test found in `test/04_1-poc.sol` to prove the success of your attack. 

:computer: Use the following line to run the test and check the success of your proof of concept:
```sh
forge test --match-path test/04_1-poc.sol -vvv # If you add a fourth v (-vvvv) you will see the traces for successful tests too, very interesting!
```


### 04_2 Basic reentrancy with subtraction, more complex

This example is a simplified share-based vault. Deposits credit a user's balance; staking converts that balance into shares. Its main functions are:

- `function deposit() external payable`
- `function withdraw(uint256 amount) external`
- `function stake(uint256 amount) external returns (uint256)`
- `function unstake(uint256 amount) external returns (uint256)`

Modify `src/04_2-template_attacker.sol` to successfully pass the test found in `test/04_2-poc.sol` to prove the success of your attack. 

:computer: Use the following line to run the test and check the success of your proof of concept:
```sh
forge test --match-path test/04_2-poc.sol -vvv # If you add a fourth v (-vvvv) you will see the traces for successful tests too, very interesting!
```


### 05 Read-only reentrancy

The last example depicts an ETH-stETH liquidity pool used as a price source by a lending protocol (see [reader_lender.sol](src/periphery_contracts/reader_lender.sol)). The stETH used here is the workshop's synthetic ETH token. Only the pool's `addLiquidity()` and `removeLiquidity()` functions have the `nonReentrant` modifier; its price getters and the lender's `borrowStEth()` and `repay()` do not.

External interactions do not all happen last: `addLiquidity()` transfers stETH in before checking the supplied ETH and reserve ratio, then mints LP tokens. `removeLiquidity()` burns LP tokens, sends ETH, and then transfers stETH.

- `function addLiquidity(uint256 stEth_amount, uint256 eth_amount) external payable nonReentrant() returns (uint256)`
- `function removeLiquidity(uint256 lp_amount) external nonReentrant() returns (uint256, uint256)`
- `function getSpotPriceStEth(uint256 amount) public view returns (uint256)`
- `function getSpotPriceEth(uint256 amount) public view returns (uint256)`

Modify `src/05-template_attacker.sol` to successfully pass the test found in `test/05-poc.sol` to prove the success of your attack. 

:computer: Use the following line to run the test and check the success of your proof of concept:
```sh
forge test --match-path test/05-poc.sol -vvv # If you add a fourth v (-vvvv) you will see the traces for successful tests too, very interesting!
```
