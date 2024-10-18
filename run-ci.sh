#!/usr/bin/env bash
## Run NuttX CI with Docker

# set -e  ## Exit when any command fails
set -x  ## Echo commands

for (( ; ; )); do
  for board in \
    arm-01 arm-02 arm-03 arm-04 \
    arm-05 arm-06 arm-07 arm-08 \
    arm-09 arm-10 arm-11 arm-12 \
    arm-13 arm-14
  do
    sudo docker pull \
      ghcr.io/apache/nuttx/apache-nuttx-ci-linux:latest
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
      ./cibuild.sh -c -A -N -R testlist/$board.dat ;
    "
  done
done
