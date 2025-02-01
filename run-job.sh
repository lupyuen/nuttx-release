#!/usr/bin/env bash
## Run a NuttX CI Job with Docker
## Read the article: https://lupyuen.codeberg.page/articles/ci2.html

echo Now running https://github.com/lupyuen/nuttx-release/blob/main/run-job.sh $1 $2
echo Called by https://github.com/lupyuen/nuttx-release/blob/main/run-ci.sh
set -x  ## Echo commands

# First Parameter is CI Job, like "arm-01"
job=$1
if [[ "$job" == "" ]]; then
  echo "ERROR: Job Parameter is missing (e.g. arm-01)"
  exit 1
fi

# Second Parameter is Instance ID, like "1"
instance=$2

## Show the System Info
set | grep TMUX || true
neofetch
sleep 10

## Download the Docker Image
sudo docker pull \
  ghcr.io/apache/nuttx/apache-nuttx-ci-linux:latest
sleep 10

## Run the CI in Docker Container
## If CI Test Hangs: Kill it after 3 hours
sudo docker run -it \
  ghcr.io/apache/nuttx/apache-nuttx-ci-linux:latest \
  /bin/bash -c "
  set -x ;
  uname -a ;
  cd ;
  pwd ;
  git clone https://github.com/apache/nuttx ;
  git clone https://github.com/apache/nuttx-apps apps ;
  pushd nuttx ; echo NuttX Source: https://github.com/apache/nuttx/tree/\$(git rev-parse HEAD) ; popd ;
  pushd apps  ; echo NuttX Apps: https://github.com/apache/nuttx-apps/tree/\$(git rev-parse HEAD) ; popd ;
  sleep 10 ;
  cd nuttx/tools/ci ;
  ( sleep 10800 ; echo Killing pytest after timeout... ; pkill -f pytest )&
  (./cibuild.sh -c -A -N -R testlist/$job.dat || echo '***** BUILD FAILED') ;
"

## Monitor the Disk Space (in case Docker takes too much)
df -H
