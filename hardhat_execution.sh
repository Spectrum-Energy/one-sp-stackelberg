#!/bin/bash

: '
This script outputs the execution time in miliseconds of each function coded in tests
in the Hardhat environment from 1 to 10 network operators.
'

echo "C;Deployment;Initialize;Input (all operators);InitEvaluation;Off-chain resolution;Output;SolveStackelberg"
for C in {1..10}
do
  result=$(C=$C npx hardhat test)
  deploy=$(echo "$result" | sed -n 5p | sed -E 's/.*\(([0-9]+)ms\)/\1/')
  initialize=$(echo "$result" | sed -n 6p | sed -E 's/.*\(([0-9]+)ms\)/\1/')
  input=$(echo "$result" | sed -n 7p | sed -E 's/.*\(([0-9]+)ms\)/\1/')
  initEvaluation=$(echo "$result" | sed -n 8p | sed -E 's/.*\(([0-9]+)ms\)/\1/')
  offChainResolution=$(echo "$result" | sed -n 9p | sed -E 's/.*\(([0-9]+)ms\)/\1/')
  output=$(echo "$result" | sed -n 10p | sed -E 's/.*\(([0-9]+)ms\)/\1/')
  solveStackelberg=$(echo "$result" | sed -n 14p | sed -E 's/.*\(([0-9]+)ms\)/\1/')
  echo "$C;$deploy;$initialize;$input;$initEvaluation;$offChainResolution;$output;$solveStackelberg"
done
