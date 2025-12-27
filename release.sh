#!/usr/bin/env bash
## Validate NuttX Release: ~/nuttx-release/release.sh starpro64 / avaota / milkvduos / oz64 / ox64 / star64 / pinephone

## TODO: Update for the release
export release=12.12.0
export candidate=RC0
export hash=54b5a8f2c3

set -e  ## Exit when any command fails
set -x  ## Echo commands

device=$1
echo ----- Validate NuttX Release for $device
echo Now running https://github.com/lupyuen/nuttx-release/blob/main/release.sh $1

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

## Login to GitHub Gists
gh auth status

## Close the `screen` session
$script_dir/close.exp

## Run the script
pushd /tmp
script $log_file \
  $script_option \
  $script_dir/release-$device.sh
popd

## Strip the control chars
tmp_file=/tmp/release-tmp-$device.log
cat $log_file \
  | tr -d '\r' \
  | tr -d '\r' \
  | sed 's/\x08/ /g' \
  | sed 's/\x1B(B//g' \
  | sed 's/\x1B\[K//g' \
  | sed 's/\x1B[<=>]//g' \
  | sed 's/\x1B\[[0-9:;<=>?]*[!]*[A-Za-z]//g' \
  | sed 's/\x1B[@A-Z\\\]^_]\|\x1B\[[0-9:;<=>?]*[-!"#$%&'"'"'()*+,.\/]*[][\\@A-Z^_`a-z{|}~]//g' \
  | cat -v \
  >$tmp_file
mv $tmp_file $log_file
echo ----- "Done! $log_file"

## Upload to GitHub Gist
cat $log_file | \
  gh gist create \
  --public \
  --desc "Validate NuttX Release for $device ($release / $candidate / $hash)" \
  --filename "validate-nuttx-release-$device-$release-$candidate-$hash.log"

## Check for hash
grep $hash $log_file || true
matches=$(grep $hash $log_file | grep -v "hash=" | wc -c)
if [ "$matches" -eq "0" ]; then
  echo ----- "ERROR: Hash $hash not found!"
  exit 1
else
  echo ----- "Hash $hash OK"
  exit 0
fi
