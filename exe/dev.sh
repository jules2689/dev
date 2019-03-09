#!/bin/bash

# Export the directory to dev.sh here so that the shell function
# can access the exe file anywhere in the system. If we didn't do this here,
# BASH_SOURCE would constantly change as we moved around the system
export DEV_SH_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

dev() {
  # Determine a data location and prep it to store a file descriptor
  DATA_DIR="${XDG_DATA_HOME:="$HOME/.local/share"}/dev"
  FD_PATH="$DATA_DIR/runtime/fd_9"
  rm -rf $FD_PATH # Make sure we're clean before executing

  # Make sure the FD runtime path exists
  mkdir -p $( dirname $FD_PATH )

  # Open File Descriptor 9
  # This is used to communicate between the ruby child process and the parent process (your shell)
  exec 9<> $FD_PATH

  # This is the location of this currently executing file
  # This allows us to evaluate the `dev` ruby file
  # Once we have this, execute it
  /usr/bin/ruby --disable-gems "$DEV_SH_DIR/dev" "$FD_PATH" "$@"

  # Finalize the process, evaluating the FD_PATH file (executes cd, changes env vars, etc)
  # Also remove the FD_PATH so as not to leak between runs
  eval $(cat $FD_PATH)
  exec 9>&-
  rm -rf $FD_PATH
}