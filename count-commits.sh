#!/bin/bash

#provide instructor when users adds -h, or --help parameter
if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
  less <<EOF
Usage: $0 [options] | [authors]

DESCRIPTION
This script prints out names of committers along with number of commits

OPTIONS
-h | --help        Print out usage
authors            List of author names separated by a space
EOF
  exit 0
fi

# if no arguments, loop through git log, sort/count commits per user, format output as user - # of commits
# Note: that awk word reversal came from stack overrflow, working on understanding it...
if [ "$#" -eq 0 ]; then
  git --no-pager log --pretty=":%an" | sort | uniq -c | sort -nr | awk -F: '{sub(/[ ]*/,"",$1);print $NF" - "$1}' | less
  exit 0
fi

# function for looping with user arugments
function loop_gitLog() {
  # get commit author from git log
  local gitlog=$(git --no-pager log --pretty="%an")
  for user in "${gitlog[@]}"; do
    echo "$user"
  done | grep -ic "$1"
  return 0
}

# if arugments are givne, loop through eahc user argument, invoke another loop that counts the number
# of commits per given user
for userArg in "$@"; do
  # requier arugments to be at least three characters
  if [ "${#userArg}" -lt 3 ]; then
    echo 'Please provide user names with at least 3 characters'
    exit 1
  else
    result=$(loop_gitLog "$userArg")
    echo "$userArg - $result"
    exit 0
  fi
done
