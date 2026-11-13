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

Both withdrawal functions send ETH before updating the caller's recorded balance. Are they equally exploitable?

The victim exposes:

- `function withdrawAll() external`
- `function withdrawSome(uint256 amount) external`
- `function deposit() external payable`
- `function userBalance(address _user) public view returns (uint256)`

Modify `src/00-template_attacker.sol` to successfully pass the test found in `test/00-poc.sol` to prove the success of your attack. Play around with both withdrawal functions: when can reentry produce a profitable or otherwise lasting impact?

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

As in `00`, `withdraw()` sends ETH before updating balances. Here, `nonReentrant` blocks nested calls to functions sharing this contract's guard, however, a new entry-point to move funds has been added!

- `function deposit() external payable`
- `function withdraw() external nonReentrant()`
- `function transferToInternally(address _recipient, uint _amount) external`

Modify `src/02-template_attacker.sol` to successfully pass the test found in `test/02-poc.sol` to prove the success of your attack. 

:computer: Use the following line to run the test and check the success of your proof of concept:
```sh
forge test --match-path test/02-poc.sol -vvv # If you add a fourth v (-vvvv) you will see the traces for successful tests too, very interesting!
```


### 03 Cross-contract reentrancy

Here, deposits mint `SyntheticETH`, a workshop mock ERC-20 representing withdrawal entitlement, not Lido's stETH. Both `deposit()` and `withdraw()` are `nonReentrant`, and the auxiliary token contract includes an additional `burnAll(address from)` function that allows an account with `BURNER_ROLE` to burn a user's entire balance.

- `function deposit() external payable nonReentrant()`
- `function withdraw() external nonReentrant()`


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

Despite its name, `Vulnerable_ERC4626` is a deliberately simplified custom share-based vault, not an ERC-4626 implementation. Deposits credit ETH balances; staking converts credits into shares. Its main functions are:

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

This ETH-stETH pool supplies spot prices to a [lending protocol](src/periphery_contracts/reader_lender.sol). Its stETH is the workshop mock. `nonReentrant` protects `addLiquidity()` and `removeLiquidity()`.

- `function addLiquidity(uint256 stEth_amount, uint256 eth_amount) external payable nonReentrant() returns (uint256)`
- `function removeLiquidity(uint256 lp_amount) external nonReentrant() returns (uint256, uint256)`
- `function getSpotPriceStEth(uint256 amount) public view returns (uint256)`
- `function getSpotPriceEth(uint256 amount) public view returns (uint256)`

Modify `src/05-template_attacker.sol` to successfully pass the test found in `test/05-poc.sol` to prove the success of your attack. 

:computer: Use the following line to run the test and check the success of your proof of concept:
```sh
forge test --match-path test/05-poc.sol -vvv # If you add a fourth v (-vvvv) you will see the traces for successful tests too, very interesting!
```
