#!/usr/bin/env bash
## Enable the macOS and Windows Builds for NuttX Mirror.
## Disable Fail-Fast, so all builds will complete.
## Remove Max Parallel, so builds can finish faster.
## https://lupyuen.codeberg.page/articles/ci3.html

set -e  #  Exit when any command fails
set -x  #  Echo commands

tmp_dir=/tmp/enable-macos-windows
rm -rf $tmp_dir
mkdir $tmp_dir
cd $tmp_dir
git clone ssh://git@github.com/NuttX/nuttx
cd nuttx

## Build on Push to Master Branch
## Change: branches:
## To:     branches:\n - master
file=.github/workflows/build.yml
tmp_file=$tmp_dir/build.yml
search='branches:'
replace='branches:\n      - master'
cat $file \
  | sed "s/$search/$replace/g" \
  >$tmp_file
mv $tmp_file $file

## Point to local arch.yml
## Change: uses: apache/nuttx/.github/workflows/arch.yml@master
## To:     uses: NuttX/nuttx/.github/workflows/arch.yml@master
search='apache\/nuttx\/.github\/workflows\/arch.yml@master'
replace='NuttX\/nuttx\/.github\/workflows\/arch.yml@master'
cat $file \
  | sed "s/$search/$replace/g" \
  >$tmp_file
mv $tmp_file $file

## Continue the Linux Builds, regardless of error
## Change: max-parallel: 12
## To:     fail-fast: false
## TODO: Linux max-parallel may change
search="max-parallel: 12"
replace="fail-fast: false"
cat $file \
  | sed "s/$search/$replace/g" \
  >$tmp_file
mv $tmp_file $file

## Continue the macOS Builds, regardless of error
## Change: max-parallel: 2
## To:     fail-fast: false
## TODO: macOS max-parallel may change
search="max-parallel: 2"
replace="fail-fast: false"
cat $file \
  | sed "s/$search/$replace/g" \
  >$tmp_file
mv $tmp_file $file

## If CI Test Hangs: Kill it after 2 hours
## Change: ./cibuild.sh
## To:     ( sleep 7200 ; echo Killing pytest after timeout... ; pkill -f pytest )& \n ./cibuild.sh'
search='                .\/cibuild.sh'
replace='                ( sleep 7200 ; echo Killing pytest after timeout... ; pkill -f pytest )\&\n                .\/cibuild.sh'
cat $file \
  | sed "s/$search/$replace/g" \
  >$tmp_file
mv $tmp_file $file

## Enable the macOS Builds
## Change: if [[ "${{ inputs.os }}" == "macOS" ]]; then
## To:     if [[ "${{ inputs.os }}" == "NOTUSED" ]]; then
file=.github/workflows/arch.yml
tmp_file=$tmp_dir/arch.yml
search="== \"macOS\""
replace="== \"NOTUSED\""
cat $file \
  | sed "s/$search/$replace/g" \
  >$tmp_file
mv $tmp_file $file

## Commit the modified files
git pull
git status
git add .
git commit --all --message="Enable macOS Builds https://github.com/lupyuen/nuttx-release/blob/main/enable-macos-windows.sh"
git push
