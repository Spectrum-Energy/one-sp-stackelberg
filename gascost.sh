#!/bin/bash

: '
This script is for getting the gas costs of the main functions of our solution.
'

export NODE_OPTIONS="--max-old-space-size=8192"

function calculate_gas_cost () {
    contract=$1
    C=$2
    result=$(contract=${contract} C=${C} REPORT_GAS=true npx hardhat test | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2};?)?)?[mGK]//g" )
    deploy=$(echo "$result" | awk -v contract="${contract}" -F  '[·\|]' '/^\| / {gsub (" ", "", $0); if($2==contract && $3 == "-") print $5 }' 2>/dev/null)
    grantRole=$(echo "$result" | awk -v contract="${contract}" -F  '[·\|]' '/^\| / {gsub (" ", "", $0); if($2==contract && $3 == "grantRole") print $6 }' 2>/dev/null)
    revokeRole=$(echo "$result" | awk -v contract="${contract}" -F  '[·\|]' '/^\| / {gsub (" ", "", $0); if($2==contract && $3 == "revokeRole") print $6 }' 2>/dev/null)
    initialize=$(echo "$result" | awk -v contract="${contract}" -F  '[·\|]' '/^\| / {gsub (" ", "", $0); if($2==contract && $3 == "initialize") print $6 }' 2>/dev/null)
    input=$(echo "$result" | awk -v contract="${contract}" -F  '[·\|]' '/^\| / {gsub (" ", "", $0); if($2==contract && $3 == "input") print $6 }' 2>/dev/null)
    initEvaluation=$(echo "$result" | awk -v contract="${contract}" -F  '[·\|]' '/^\| / {gsub (" ", "", $0); if($2==contract && $3 == "initEvaluation") print $6 }' 2>/dev/null)
    output=$(echo "$result" | awk -v contract="${contract}" -F  '[·\|]' '/^\| / {gsub (" ", "", $0); if($2==contract && ($3 == "output" || $3 == "solveStackelbergGame")) print $6 }' 2>/dev/null)
    echo "$contract;$C;$deploy;$grantRole;$revokeRole;$initialize;$input;$initEvaluation;$output"
}

echo "Contract;C;Deploy;grantRole;revokeRole;initialize;input;initEvaluation;output"
for C in $(seq 1 1 10); do calculate_gas_cost "StackelbergGameOffChain" $C; done
for C in $(seq 1 1 10); do calculate_gas_cost "StackelbergGameOnChain" $C; done