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
check_output "Command-line Argument Low" "Number must be between 0-100"

timeout 5 $PROGRAM 101 > $OUT
check_output "Command-line Argument High" "Number must be between 0-100"

timeout 5 $PROGRAM notanumber > $OUT
check_output "Command-line Argument NAN" "$PROGRAM [-o|-d] num"

# TC8 Normal Run
timeout 5 $PROGRAM 7 > $OUT
check_output "Normal Run 1" "0xd"

timeout 5 $PROGRAM 100 > $OUT
check_output "Normal Run 2" "0x1333db76a7c594bfc3"

# TC9 Octal Output
timeout 5 $PROGRAM -o 7 > $OUT
check_output "Octal Output Option 1" "0o15"

timeout 5 $PROGRAM -o 100 > $OUT
check_output "Octal Output Option 2" "0o46317333552370545137703"

rm $OUT
