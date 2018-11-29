#!/bin/sh

# Testing script for FIRE
# 
#  Compile, run, and check the output of each test against expected result
#  Expected failures run diff against the expected error, expected passes check against the expected output of the file

# Path to the LLVM interpreter
LLI="lli"

# Path to the LLVM compiler
LLC="llc"

# Path to the C compiler
CC="gcc"

# Path to the Fire compiler
FIRE="./Fire.native"

# Set time limit for all operations
ulimit -t 30

globallog=testall.log
rm -f $globallog
error=0
globalerror=0

keep=0

Usage() {
    echo "Usage: testall.sh [options] [.Fire files]"
    echo "-h    Print this help"
    exit 1
}
