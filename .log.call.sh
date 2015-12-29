#! /usr/bin/env sh

#---------#
# Imports #
#---------#

if [ -z "${IMPORT_SRC+x}" ]; then
  . "${LIBRARY_FXNS}/import"
fi
import "log"

log 1 "entering .log.call"

#--------#
# Script #
#--------#

usage ()
{
  out=$1
  printf "\nUsage: ./.log.call [-p] [-s <level>] [-h]\n" >&$out
  printf "  -p: Prints the current stdout level\n" >&$out
  printf "  -s: Sets stdout level to the integer <level> (must be between 1\n"
  printf "                and 5, where 5 implies no stdout logging)\n" >&$out
  printf "  -h: Prints usage\n\n" >&$out
}

if [ "$#" = 0 ]; then
  log 5 "Need at least one argument"
  usage 2
  exit 1
fi

while getopts ":ps:h" opt; do
  case $opt in
    p)
      log_print_stdout_level
    ;;
    h)
      usage 1
      exit 0
    ;;
    s)
      log_set_stdout_level "${OPTARG}"
    ;;
    \?)
      log 5 "Invalid option given: -${OPTARG}"
      usage 2
      exit 1
    ;;
    :)
      log 5 "Option -${OPTARG} requires an argument"
      usage 2
      exit 2
    ;;
  esac
done

log 1 "exiting .log.call"
