#!/usr/bin/env bash
## Sync NuttX Mirror, Build NuttX Mirror and Ingest GitHub Actions Logs
## (1) Watch for Updates to NuttX Repo
## (2) Discard "Enable macOS" commit from NuttX Mirror
## (3) Sync NuttX Mirror with NuttX Repo
## (4) Build NuttX Mirror and Ingest GitHub Actions Logs
## (5) Repeat forever
## https://lupyuen.github.io/articles/ci4

set -e  #  Exit when any command fails
set -x  #  Echo commands

## Get the Script Directory
script_path="${BASH_SOURCE}"
script_dir="$(cd -P "$(dirname -- "${script_path}")" >/dev/null 2>&1 && pwd)"

tmp_dir=/tmp/sync-build-ingest
rm -rf $tmp_dir
mkdir $tmp_dir
cd $tmp_dir
git clone https://github.com/apache/nuttx upstream
git clone ssh://git@github.com/NuttX/nuttx downstream

set +x ; echo "**** Waiting for Build to Complete then Ingest GitHub Actions Logs..." ; set -x
pushd $script_dir/../ingest-nuttx-builds
./github.sh  ## https://github.com/lupyuen/ingest-nuttx-builds/blob/main/github.sh
popd

## Repeat forever
for (( ; ; )); do

  set +x ; echo "**** Checking Downstream Commit: Enable macOS Builds..." ; set -x
  pushd downstream
  git pull
  downstream_msg=$(git log -1 --format="%s")
  if [[ "$downstream_msg" != "Enable macOS Builds"* ]]; then
    set +x ; echo "**** ERROR: Expected Downstream Commit to be 'Enable macOS Builds' but found: $downstream_msg" ; set -x
    exit 1
  fi
  popd

  set +x ; echo "**** Watching for Updates to NuttX Repo..." ; set -x
  ## Get the Latest Upstream Commit.
  pushd upstream
  git pull
  upstream_date=$(git log -1 --format="%cI")
  git --no-pager log -1
  popd

  ## Get the Latest Downstream Commit (skip the "Enable macOS Builds")
  pushd downstream
  downstream_date=$(git log -1 --format="%cI" HEAD~1)
  git --no-pager log -1 HEAD~1
  popd

  ## If No Updates: Try again
  if [[ "$upstream_date" == "$downstream_date" ]]; then
    set +x ; echo "**** Waiting for upstream updates..." ; set -x
    date ; sleep 900
    continue
  fi

  set +x ; echo "**** Discarding 'Enable macOS' commit from NuttX Mirror..." ; set -x
  pushd downstream
  git --no-pager log -1
  git reset --hard HEAD~1
  git status
  git push -f
  popd
  sleep 10

  set +x ; echo "**** Syncing NuttX Mirror with NuttX Repo..." ; set -x
  gh repo sync NuttX/nuttx --force
  pushd downstream
  git pull
  git status
  git --no-pager log -1
  popd
  sleep 10

  set +x ; echo "**** Building NuttX Mirror..." ; set -x
  $script_dir/enable-macos-windows.sh  ## https://github.com/lupyuen/nuttx-release/blob/main/enable-macos-windows.sh

  set +x ; echo "**** Waiting for Build to start..." ; set -x
  date ; sleep 900

  set +x ; echo "**** Waiting for Build to Complete then Ingest GitHub Actions Logs..." ; set -x
  pushd $script_dir/../ingest-nuttx-builds
  ./github.sh  ## https://github.com/lupyuen/ingest-nuttx-builds/blob/main/github.sh
  popd

  set +x ; echo "**** Done!" ; set -x
  date ; sleep 900
done
