#!/bin/env bash

# sets it to fail if there are any weirdness like unbound variables
set -euo pipefail

REGEX=$1
PREV_BRANCH=$2
CURR_BRANCH=$3

main() {
    echo "Processing regex: $REGEX, checking on prev_branch: $PREV_BRANCH -- curr_branch: $CURR_BRANCH"
}

# references getopts from https://stackoverflow.com/a/15408583
help_msg() {
    echo "Usage: $0 [-h] [-f FILE]"
    echo " -h Help. Display this message and quit."
    echo " -v Version. Print version number and quit."
    echo " -f Specify git paths file FILE"
}

version() {
    echo "version 1.0 of git-commit-searcher"
}

FILE=""
SOURCE=""
TARGET=""

# logic behind https://stackoverflow.com/a/18414091 the colons for optspecs
optspec="f:s:t::hv"
while getopts "$optspec" optchar
do
    case "${optchar}" in
        h)
            help_msg 
            exit 0
            ;;
        v)
            version
            exit 0
            ;;
        f)
            FILE=${OPTARG}
            ;;
        s)
            SOURCE=${OPTARG}
            ;;
        t)
            TARGET=${OPTARG}
            ;;
        \?)
            echo "Missing args please pass file name"
            help_msg
            exit 1
            ;;
    esac
done    

echo "Processing file: $FILE, source: $SOURCE, target: $TARGET"