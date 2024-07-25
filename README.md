# Cell-Free Massive MIMO with Multiple Operators

This repository contains the source code for the article whose title is _Dynamic Spectrum Sharing in a Blockchain Enabled Network With Multiple Cell-Free Massive MIMO Virtual Operators_ ([https://ieeexplore.ieee.org/document/10533732](https://ieeexplore.ieee.org/document/10533732)).

## Table of Contents

- [Directory structure](#directory-structure)
- [Install](#install)
- [Usage](#usage)
- [Documentation](#documentation)

## Directory structure

    .
    ├── contracts               # Solidity smart contracts
    ├── coverage                # Test coverage of smart contracts (see index.html)
    ├── docs                    # Auto-generated documentation files
    ├── scripts                 # Scripts to generate the figures
    |   ├── performance         # Performance files
    |   |   ├── data            # Costs of our solution
    |   |   ├── figures         # Figures of cost in gas units and USD
    └── test                    # Automated tests

## Install

Prerequisites:
- node >=16
- Matlab and "Statistics and Machine Learning Toolbox".

Install project dependencies:
```shell
npm install
```

## Usage

Run tests (default values: contract = both and C = 5):
```shell
contract=[StackelbergGameOffChain|StackelbergGameOnChain|both] C=[C] REPORT_GAS=true npx hardhat test
```

Get tests coverage:
```shell
npx hardhat coverage
```

Get cost in gas units of the deployment and the main functions of the smart contracts:
```shell
./gascost.sh
```

Get the execution time of the deployment and the main functions in the Hardhat environment:
```shell
./hardhat_execution.sh
```

## Documentation

Generate documentation of all .sol in `contracts` into [docs/index.md](docs/index.md):

```shell
npx hardhat docgen
```