#!/usr/bin/env bash
## Run NuttX CI with Docker:
##   sudo apt install gh glab
##   sudo sh -c '. ../github-token.sh && ./run-ci.sh 1'
##   sudo sh -c '. ../gitlab-token.sh && ./run-ci.sh 1'
## Change '1' to a Unique Instance ID. Each instance of this script will run under a different Instance ID.

## GitHub Token: Should have Gist Permission
## github-token.sh contains:
##   export GITHUB_TOKEN=...

## GitLab Token: User Settings > Access tokens > Select Scopes
##   api: Grants complete read/write access to the API, including all groups and projects, the container registry, the dependency proxy, and the package registry.
## gitlab-token.sh contains:
##   export GITLAB_TOKEN=...
##   export GITLAB_USER=lupyuen
##   export GITLAB_REPO=nuttx-build-log
## Which means the GitLab Snippets will be created in the existing GitLab Repo "lupyuen/nuttx-build-log"

## Read the article: https://lupyuen.codeberg.page/articles/ci2.html

echo Now running https://github.com/lupyuen/nuttx-release/blob/main/run-ci.sh $1
set -x  ## Echo commands

# Optional Parameter is Instance ID, like 1.
# Each instance of this script will run under a different Instance ID.
instance=$1
device=ci$instance

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
    "$script_dir/run-job.sh $job $instance"
  popd
}

## Strip the control chars
function clean_log {
  local tmp_file=/tmp/release-$device-tmp.log
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
}

## Search for Errors and Warnings
function find_messages {
  local tmp_file=/tmp/release-$device-tmp.log
  local msg_file=/tmp/release-$device-msg.log
  local pattern='^(.*):(\d+):(\d+):\s+(warning|fatal error|error):\s+(.*)$'
  grep '^\*\*\*\*\*' $log_file \
    > $msg_file
  grep -P "$pattern" $log_file \
    | uniq \
    >> $msg_file
  cat $msg_file $log_file >$tmp_file
  mv $tmp_file $log_file
}

## Upload to GitLab Snippet or GitHub Gist
function upload_log {
  local job=$1
  local nuttx_hash=$2
  local apps_hash=$3
  local desc="[$job] CI Log for nuttx @ $nuttx_hash / nuttx-apps @ $apps_hash"
  local filename="ci-$job.log"
  if [[ "$GITLAB_TOKEN" != "" ]]; then
    if [[ "$GITLAB_USER" == "" ]]; then
      echo '$GITLAB_USER is missing (e.g. lupyuen)'
      exit 1
    fi
    if [[ "$GITLAB_REPO" == "" ]]; then
      echo '$GITLAB_REPO is missing (e.g. nuttx-build-log)'
      exit 1
    fi
    cat $log_file | \
      glab snippet new \
        --repo "$GITLAB_USER/$GITLAB_REPO" \
        --visibility public \
        --title "$desc" \
        --filename "$filename"
  else
    cat $log_file | \
      gh gist create \
        --public \
        --desc "$desc" \
        --filename "$filename"
  fi
}

## Skip to a Random CI Job. Assume max 32 CI Jobs.
let "skip = $RANDOM % 32"
echo Skipping $skip CI Jobs...

## Repeat forever for All CI Jobs
for (( ; ; )); do
  for job in \
    arm-01 arm-02 arm-03 arm-04 \
    arm-05 arm-06 arm-07 arm-08 \
    arm-09 arm-10 arm-11 arm-12 \
    arm-13 arm-14 \
    arm64-01 \
    other \
    risc-v-01 risc-v-02 risc-v-03 risc-v-04 \
    risc-v-05 risc-v-06 \
    sim-01 sim-02 sim-03 \
    x86_64-01 \
    xtensa-01 xtensa-02
  do
    ## Skip to a Random CI Job
    if [[ $skip -gt 0 ]]; then
      let skip--
      continue
    fi

    ## Run the CI Job and find errors / warnings
    run_job $job
    clean_log
    find_messages

    ## Get the hashes for NuttX and Apps
    nuttx_hash=$(
      cat $log_file \
      | grep --only-matching -E "nuttx/tree/[0-9a-z]+" \
      | grep --only-matching -E "[0-9a-z]+$" --max-count=1
    )
    apps_hash=$(
      cat $log_file \
      | grep --only-matching -E "nuttx-apps/tree/[0-9a-z]+" \
      | grep --only-matching -E "[0-9a-z]+$" --max-count=1
    )

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
