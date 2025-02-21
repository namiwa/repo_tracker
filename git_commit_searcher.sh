#!/bin/env bash

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

# logic behind https://stackoverflow.com/a/18414091 the colons for optspecs
# https://stackoverflow.com/q/18414054 using ase bse line for multi flag 
  if [[ "$1" =~ ^((-{1,2})([Hh]$|[Hh][Ee][Ll][Pp])|)$ ]]; then
    echo "Please input flags"
    help_msg; exit 1
  else
    while [[ $# -gt 0 ]]; do
      opt="$1"
      shift;
      current_arg="$1"
      if [[ "$current_arg" =~ ^-{1,2}.* ]]; then
        echo "WARNING: You may have left an argument blank. Double check your command." 
      fi
      case "$opt" in
        "-s"|"--source"        ) SOURCE="$1"; shift;;
        "-t"|"--target"        ) TARGET="$1"; shift;;
        "-f"|"--file"          ) FILE="$1"; shift;;
        "-h"|"--help"          ) help_msg; exit 0;;
        "-v"|"--version"       ) version_msg; exit 0;;
        *                      ) echo "ERROR: Invalid option: \""$opt"\"" >&2
                                 exit 1;;
      esac
    done
  fi

  if [[ "$FILE" == "" || "$SOURCE" == "" || "$TARGET" == "" ]]; then
    echo "ERROR: Options -f, -s and -t require arguments." >&2
    exit 1
  fi

# TODO reject if not populated
main $FILE $SOURCE $TARGET