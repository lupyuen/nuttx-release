#!/usr/bin/env bash
## Run NuttX CI with Docker
## Read the article: https://lupyuen.codeberg.page/articles/ci2.html

echo Now running https://github.com/lupyuen/nuttx-release/blob/main/run-ci.sh
set -x  ## Echo commands
device=ci

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

## Run the job
function run_job {
  local job=$1
  pushd /tmp
  script $log_file \
    $script_option \
    "$script_dir/run-job.sh $job"
  popd
}

## Strip the control chars
function clean_log {
  local tmp_file=/tmp/release-tmp.log
  cat $log_file \
    | tr -d '\r' \
    | tr -d '\r' \
    | sed 's/\x08/ /g' \
    | sed 's/\x1B(B//g' \
    | sed 's/\x1B\[K//g' \
    | sed 's/\x1B[<=>]//g' \
    | sed 's/\x1B\[[0-9:;<=>?]*[!]*[A-Za-z]//g' \
    | sed 's/\x1B[@A-Z\\\]^_]\|\x1B\[[0-9:;<=>?]*[-!"#$%&'"'"'()*+,.\/]*[][\\@A-Z^_`a-z{|}~]//g' \
    >$tmp_file
  mv $tmp_file $log_file
  echo ----- "Done! $log_file"
}

## Search for Errors and Warnings
function find_messages {
  local tmp_file=/tmp/release-tmp.log
  local msg_file=/tmp/release-msg.log
  local pattern='^(.*):(\d+):(\d+):\s+(warning|fatal error|error):\s+(.*)$'
  grep '^\*\*\*\*\*' $log_file \
    > $msg_file
  grep -P "$pattern" $log_file \
    | uniq \
    >> $msg_file
  cat $msg_file $log_file >$tmp_file
  mv $tmp_file $log_file
}

## Upload to GitHub Gist
function upload_log {
  local job=$1
  local nuttx_hash=$2
  local apps_hash=$3
  cat $log_file | \
    gh gist create \
    --public \
    --desc "[$job] CI Log for nuttx @ $nuttx_hash / nuttx-apps @ $apps_hash" \
    --filename "ci-$job.log"
}

## Repeat forever for All CI Jobs
for (( ; ; )); do
  for job in \
    arm-01 arm-02 arm-03 arm-04 \
    arm-05 arm-06 arm-07 arm-08 \
    arm-09 arm-10 arm-11 arm-12 \
    arm-13 arm-14
  do
    ## Run the CI Job and find errors / warnings
    run_job $job
    clean_log
    find_messages

    ## Get the hashes for NuttX and Apps
    nuttx_hash=$(grep --only-matching -E "nuttx/tree/[0-9a-z]+" $log_file | grep --only-matching -E "[0-9a-z]+$")
    apps_hash=$(grep --only-matching -E "nuttx-apps/tree/[0-9a-z]+" $log_file | grep --only-matching -E "[0-9a-z]+$")

    ## Upload the log
    upload_log $job $nuttx_hash $apps_hash
    sleep 10
  done

  ## Free up the Docker disk space
  sudo docker system prune --force
done

## Here's how we delete the 20 latest gists
function delete_gists {
  local gist_ids=$(sudo gh gist list --limit 20 | cut --fields=1)
  for gist_id in $gist_ids; do
    sudo gh gist delete $gist_id
  done
}
