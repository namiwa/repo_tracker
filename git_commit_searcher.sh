#!/bin/env bash

# unofficial bash strict mode: https://gist.github.com/robin-a-meade/58d60124b88b60816e8349d1e3938615
set -euo pipefail

# sets it to fail if there are any weirdness like unbound variables
check_deps() {
  deps=("git" "sort" "uniq" "sed" "grep" "awk" "ls")
  for dep in ${deps[@]}; do
    p="$(command -v $dep)"
    echo "checking path of dep: $dep -- $p"
    if ! [ -x "$p" ]; then
      echo "Error: $dep is not installed." >&2
      exit 1
    fi
  done
  echo "all deps are present"
}

check_file_exists() {
  # spaces and curly braces are important in bash
  if ! [ -f "$1" ]; then
    echo "invalid file path: $1"
    exit 1
  fi
}

clean_up_output_file() {
  if [ -f "./output.txt" ]; then
    echo "removing previous output file"
    rm ./output.txt
    return
  fi
  echo "skipping output file deletion as it is not present"
  echo "commit,message,pattern,repo" > ./output.txt
}

main() {
  check_deps
  clean_up_output_file
  echo "Processing targetReposFile: $1, checking on prev_branch: $2 --> curr_branch: $3, regex: $4"
  check_file_exists $1
  rm ./.gitignore
  echo output.txt > ./.gitignore
  # looping from https://stackoverflow.com/a/4622581
  # create a data folder is ignore there
  while IFS= read -r repoUrl || [[ "$repoUrl" ]]; do
    echo "processing repo: $repoUrl"
    dirName=$(basename -- "$repoUrl")
    dirName="${dirName%.*}"
    echo "$dirName"
    if cd "./$dirName"; then
      echo "skipping pull as repo is present"
    else
      git clone $repoUrl;
    fi
    # Continue with git log parsing in the repo itself
    if ! git fetch origin $2; then
      echo "skipping $repoUrl since branch $2 not found"
      cd ..
      echo "$dirName" >> "./.gitignore"
      continue
    fi
    if ! git fetch origin $3; then
      echo "skipping $repoUrl since branch $3 not found"
      cd ..
      echo "$dirName" >> "./.gitignore"
      continue
    fi
    LOG_DATA="$(git log --oneline --merges --first-parent origin/$2..origin/$3 | grep -e $4)"
    #TODO: make tabular with commit, desc, matched string and repoUrl
    FORMATTED_DATA="$(echo "$LOG_DATA" | sed $'s/ \{1,\}/\,/')"
    FORMATTED_DATA="$(echo "$FORMATTED_DATA" | sed "s/$/,$4,$dirName/")"
    cd ..
    echo "$dirName" >> "./.gitignore"
    echo "$FORMATTED_DATA" >> "./output.txt"
  done < $1
  echo "processed all repos from $1, commit message searching completed successfully"
  exit 0
}

# references getopts from https://stackoverflow.com/a/15408583
help_msg() {
  echo "Usage: $0 [-h] [-f FILE]"
  echo " -h Help. Display this message and quit."
  echo " -v Version. Print version number and quit."
  echo " -f Specify git paths file FILE"
  echo " -s Specify git source branch (oldest branch)"
  echo " -t Specify git target branch (most recent branch)"
  echo " -r Specify regex to search for"
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
      "-r"|"--regex"         ) REGEX="$current_arg"; shift;;
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

  if [[ "$FILE" == "" || "$SOURCE" == "" || "$TARGET" == "" || "$REGEX" == "" ]]; then
    echo "ERROR: Options -f, -s and -t require arguments." >&2
    exit 1
  fi

main $FILE $SOURCE $TARGET $REGEX