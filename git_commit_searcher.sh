#!/bin/env bash

# unofficial bash strict mode: https://gist.github.com/robin-a-meade/58d60124b88b60816e8349d1e3938615
set -euo pipefail

# sets it to fail if there are any weirdness like unbound variables

main() {
    echo "Processing targetRepos: $1, checking on prev_branch: $2 --> curr_branch: $3"
}

# references getopts from https://stackoverflow.com/a/15408583
help_msg() {
    echo "Usage: $0 [-h] [-f FILE]"
    echo " -h Help. Display this message and quit."
    echo " -v Version. Print version number and quit."
    echo " -f Specify git paths file FILE"
    echo " -s Specify git source branch (oldest branch)"
    echo " -t Specify git target branch (most recent branch)"
}

version_msg() {
    echo "version 1.0 of git-commit-searcher"
}

DEFAULTMISSINGVAL="default-missing-val"

# https://stackoverflow.com/a/2013573 -- default values
CHECKPARAM="${1:-$DEFAULTMISSINGVAL}"

# https://stackoverflow.com/q/18414054 using ase bse line for multi flag 
# logic behind https://stackoverflow.com/a/18414091 the colons for optspecs
if [[ $CHECKPARAM == $DEFAULTMISSINGVAL  ]]; then
  echo "Missing required flags"
  help_msg; exit 1
else
  while [[ $# -gt 0 ]]; do
    opt="$1"
    shift;
    current_arg="${1:-$DEFAULTMISSINGVAL}"
    case "$opt" in
      "-s"|"--source"        ) SOURCE="$current_arg"; shift;;
      "-t"|"--target"        ) TARGET="$current_arg"; shift;;
      "-f"|"--file"          ) FILE="$current_arg"; shift;;
      "-h"|"--help"          ) help_msg; exit 0;;
      "-v"|"--version"       ) version_msg; exit 0;;
      *                      ) echo "ERROR: Invalid option: \""$opt"\"" >&2
                                exit 1;;
    esac
    if [[ "$current_arg" == $DEFAULTMISSINGVAL ]]; then
      echo "WARNING: You may have left an argument blank. Double check your command." 
    fi
  done
fi

  if [[ "$FILE" == "" || "$SOURCE" == "" || "$TARGET" == "" ]]; then
    echo "ERROR: Options -f, -s and -t require arguments." >&2
    exit 1
  fi

main $FILE $SOURCE $TARGET