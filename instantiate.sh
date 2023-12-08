#!/usr/bin/env bash

# Parse command line arguments
# Ref: https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash
FORCE_RESOLVE="false"
SKIP_INSTALL="false"
SOURCE_DOTENV="true"
# As long as there is at least one more argument, keep looping
while [[ $# -gt 0 ]]; do
  key="$1"
  case "$key" in
    -f|--force-resolve)
    shift # past the key and to the value
    FORCE_RESOLVE="$1"
    ;;
    -s|--skip-install)
    shift # past the key and to the value
    SKIP_INSTALL="$1"
    ;;
    -d|--source-dotenv)
    shift # past the key and to the value
    SOURCE_DOTENV="$1"
    ;;
    *)
    # Do whatever you want with extra options
    echo "Unknown option '$key'"
    ;;
  esac
  # Shift after checking all the cases to get the next option
  shift
done

# On Windows, this scripts only support msys(Git Bash) or cygwin
julia --project=. --startup-file=no instantiate.jl "$FORCE_RESOLVE" "$SKIP_INSTALL"


if [ "$SOURCE_DOTENV" ]; then
  # shellcheck disable=SC1091
  source .env
fi