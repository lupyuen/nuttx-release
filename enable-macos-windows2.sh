#!/usr/bin/env bash
## NOTE: This is the revised version for Termux (which doesn't support /tmp)
## Enable the macOS and Windows Builds for NuttX Mirror

set -e  #  Exit when any command fails
set -x  #  Echo commands

tmp_dir=$TMP/enable-macos-windows
rm -rf $tmp_dir
mkdir $tmp_dir
cd $tmp_dir
git clone https://github.com/NuttX/nuttx
cd nuttx

## Change: uses: apache/nuttx/.github/workflows/arch.yml@master
## To:     uses: NuttX/nuttx/.github/workflows/arch.yml@master
file=.github/workflows/build.yml
tmp_file=$tmp_dir/build.yml
search="apache\/nuttx\/.github\/workflows\/arch.yml"
replace="NuttX\/nuttx\/.github\/workflows\/arch.yml"
cat $file \
  | sed "s/$search/$replace/g" \
  >$tmp_file
mv $tmp_file $file

## Change: max-parallel: 12
## To:     max-parallel: 12\n      fail-fast: false
## TODO: max-parallel may change
search="max-parallel: 12"
replace="max-parallel: 12\n      fail-fast: false"
cat $file \
  | sed "s/$search/$replace/g" \
  >$tmp_file
mv $tmp_file $file

## Change: max-parallel: 2
## To:     max-parallel: 2\n      fail-fast: false
## TODO: macOS max-parallel may change
search="max-parallel: 2"
replace="max-parallel: 2\n      fail-fast: false"
cat $file \
  | sed "s/$search/$replace/g" \
  >$tmp_file
mv $tmp_file $file

## Change: if [[ "${{ inputs.os }}" != "Linux" ]]; then
## To:     if [[ "${{ inputs.os }}" == "NOTUSED" ]]; then
file=.github/workflows/arch.yml
tmp_file=$tmp_dir/arch.yml
search="!= \"Linux\""
replace="== \"NOTUSED\""
cat $file \
  | sed "s/$search/$replace/g" \
  >$tmp_file
mv $tmp_file $file

## Commit the modified files
git pull
git status
git add .
git commit --all --message="Enable macOS and Windows Builds"
git push
