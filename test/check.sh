#!/bin/bash
PROGRAM=./fibonacci
OUT=.output.txt

GREEN='\033[32m'
RED='\033[31m'
NC='\033[0m'

function check_output {
	if grep -qF "$2" $OUT; then
		echo -e "[${GREEN}PASS${NC}] $1"
	else
		echo -e "[${RED}FAIL${NC}] $1"
	fi
}

# TC6 No Command-line Arguments
timeout 5 $PROGRAM > $OUT
check_output "No Command-line Arguments" "$PROGRAM [-o|-d] num"

# TC7 Invalid Command-line Arguments
timeout 5 $PROGRAM -2 > $OUT
check_output "Invalid Command-line Arguments" "Number must be between 0-100"

# TC8 Normal Run
timeout 5 $PROGRAM 7 > $OUT
check_output "Normal Run" "0xD"

# TC9 Octal Output
timeout 5 $PROGRAM -o 7 > $OUT
check_output "Octal Output Option" "0o15"

# TC10 Decimal Output
timeout 5 $PROGRAM -d 7 > $OUT
check_output "Decimal Output Option" "13"

rm $OUT
