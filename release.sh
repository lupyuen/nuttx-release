#!/usr/bin/env bash
## Validate NuttX Release: release.sh milkvduos / ox64 / star64 / pinephone

set -e  ## Exit when any command fails
set -x  ## Echo commands

## TODO: Update for the release
release=12.5.1
candidate=RC0
hash=abc

device=$1
echo ----- Validate NuttX Release for $device

## Get the Script Directory
script_path="${BASH_SOURCE}"
script_dir="$(cd -P "$(dirname -- "${script_path}")" >/dev/null 2>&1 && pwd)"
log_file=/tmp/release-$device.log

## Get the `script` option
if [ "`uname`" == "Linux" ]; then
  script_option=-c
else
  script_option=
fi

## Run the script
pushd /tmp
script $log_file \
  $script_option \
  $script_dir/release-$device.sh
popd
echo Done! $log_file

## Check for hash
grep $hash $log_file || true
matches=$(grep $hash $log_file | wc -c)
if [ "$matches" -eq "0" ]; then
  echo ----- "ERROR: Hash $hash not found!"
  exit 1
else
  echo ----- "Hash $hash OK"
  exit 0
fi
