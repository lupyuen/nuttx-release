#!/usr/bin/env bash
## Run a NuttX CI Job with Docker
## Read the article: https://lupyuen.codeberg.page/articles/ci2.html

echo Now running https://github.com/lupyuen/nuttx-release/blob/main/run-job.sh
echo Called by https://github.com/lupyuen/nuttx-release/blob/main/run-ci.sh
set -x  ## Echo commands

# Parameter is CI Job, like "arm-01"
job=$1

## Show the System Info
neofetch
sleep 10

## Download the Docker Image
sudo docker pull \
  ghcr.io/apache/nuttx/apache-nuttx-ci-linux:latest
sleep 10

## Run the CI in Docker Container
sudo docker run -it \
  ghcr.io/apache/nuttx/apache-nuttx-ci-linux:latest \
  /bin/bash -c "
  cd ;
  pwd ;
  git clone https://github.com/apache/nuttx ;
  git clone https://github.com/apache/nuttx-apps apps ;
  pushd nuttx ; echo NuttX Source: https://github.com/apache/nuttx/tree/\$(git rev-parse HEAD) ; popd ;
  pushd apps  ; echo NuttX Apps: https://github.com/apache/nuttx-apps/tree/\$(git rev-parse HEAD) ; popd ;
  sleep 10 ;
  cd nuttx/tools/ci ;
  ./cibuild.sh -c -A -N -R testlist/$job.dat ;
  df -H ;
"
