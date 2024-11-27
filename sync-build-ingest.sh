#!/usr/bin/env bash
## Sync NuttX Mirror, Build NuttX Mirror and Ingest GitHub Actions Logs
## (1) Watch for Updates to NuttX Repo
## (2) Discard "Enable macOS" commit from NuttX Mirror
## (3) Sync NuttX Mirror with NuttX Repo
## (4) Build NuttX Mirror and Ingest GitHub Actions Logs
## (5) Repeat forever
## https://lupyuen.codeberg.page/articles/ci3.html

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

## Repeat forever
for (( ; ; )); do

  echo "Checking Downstream Commit: Enable macOS Builds..."
  pushd downstream
  git pull
  downstream_msg=$(git log -1 --format="%s")
  if [[ "$downstream_msg" != "Enable macOS Builds"* ]]; then
    echo "Expected Downstream Commit to be 'Enable macOS Builds' but found: $downstream_msg"
    exit 1
  fi
  popd

  echo "Watching for Updates to NuttX Repo..."
  ## Get the Latest Upstream Commit.
  pushd upstream
  git pull
  upstream_date=$(git log -1 --format="%cI")
  git --no-pager log --decorate=short --pretty=oneline -1
  popd

  ## Get the Latest Downstream Commit (skip the "Enable macOS Builds")
  pushd downstream
  downstream_date=$(git log -1 --format="%cI" HEAD~1)
  git --no-pager log --decorate=short --pretty=oneline -1
  popd

  ## If No Updates: Try again
  if [[ "$upstream_date" == "$downstream_date" ]]; then
    echo "Waiting for upstream updates..."
    date ; sleep 900
    continue
  fi

  echo "Discarding 'Enable macOS' commit from NuttX Mirror..."
  pushd downstream
  git --no-pager log --decorate=short --pretty=oneline -1
  git reset --hard HEAD~1
  git status
  git push -f
  popd
  sleep 10

  echo "Syncing NuttX Mirror with NuttX Repo..."
  gh repo sync NuttX/nuttx --force
  pushd downstream
  git pull
  git status
  git --no-pager log --decorate=short --pretty=oneline -1
  popd
  sleep 10

  echo "Building NuttX Mirror and Ingesting GitHub Actions Logs..."
  $script_dir/../ingest-nuttx-builds/build-github-and-ingest.sh 
  echo "Done!"
  date ; sleep 900
done
