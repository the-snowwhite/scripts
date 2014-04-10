#!/bin/bash

# script to build a test branch from git in a scratch directory

# ----->   The defaults below are valid for the beaglebone SD card build ONLY
# ----->   please review and edit for other platforms 

# This script assumes the platform already was already used to
# build from source, i.e. has all build prerequisites installed.

# the repository and branch settings are for the machinekit master branch.
# please adapt as needed.

## ----- begin configurable options ---

# this is where the test build will go. 
SCRATCH=${HOME}/machinekit-test

# git repository to pull from
REPO=git://github.com/machinekit/machinekit.git

# the origin to use
ORIGIN=github-machinekit

# the branch to build
BRANCH=master

# the configure command line.

# for the Beaglebone, use:
CONFIG_ARGS=" --with-xenomai  --with-posix --with-platform=beaglebone"

# for the raspberry, use this:
#CONFIG_ARGS=" --with-xenomai  --with-posix --with-platform=raspberry"

# echo commands during execution - very verbose
# comment out once you trust this
set -x

# comment out these lines before running this script:
echo "please review and edit this script before use."
exit 1

# ----------- end configurable options --------

# fail the script on any error
set -e 

# refuse to clone into an existing directory.
if [ -d "$SCRATCH" ]; then
    echo the target directory $SCRATCH already exists.
    echo please remove or rename this directory and run again.
    exit 1
fi 

# $SCRATCH does not exist. Make a shallow git clone into it.
# make sure you have around 200MB free space.

git clone -b "$BRANCH" -o "$ORIGIN" --depth 1 "$REPO" "$SCRATCH"

echo building in "$SCRATCH/src"
cd "$SCRATCH/src"
echo now in directory: `pwd` 

# QA: log what just was checked out

# log the origin
git remote -v

# show the top commit 
git log -n1

# show that the branch has properly been checked out
git status

# configure and build
sh autogen.sh

./configure ${CONFIG_ARGS}

make 

echo make completed

# check the system configuration (logging etc)

../scripts/check-system-configuration.sh

echo "looks like the build succeeded!"
echo "you now need to run:"

echo "  cd $SCRATCH/src"
echo "  sudo make setuid"

echo "to run linuxcnc from this build, please execute first:"
echo ". $SCRATCH/scripts/rip-environment" 
