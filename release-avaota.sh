#!/usr/bin/env bash
## Validate NuttX Release for Avaota-A1
## Based on https://cwiki.apache.org/confluence/display/NUTTX/Validating+a+staged+Release
## Sample Output: https://gist.github.com/lupyuen/7c9b0da52a2d445c7c559e001ea73126
## clear && ~/nuttx-release/release.sh avaota
echo ----- Validate NuttX Release for Avaota-A1
echo release=$release
echo candidate=$candidate
echo hash=$hash
echo https://github.com/lupyuen/nuttx-release/blob/main/release-avaota.sh

## TODO: Update PATH for Arm GNU Toolchain aarch64-none-elf
## export PATH="$HOME/arm-gnu-toolchain-13.2.Rel1-x86_64-aarch64-none-elf/bin:$PATH"

set -e  ## Exit when any command fails
set -x  ## Echo commands

## Server that controls Avaota-A1
export AVAOTA_SERVER=thinkcentre

## Get the Script Directory
script_path="${BASH_SOURCE}"
script_dir="$(cd -P "$(dirname -- "${script_path}")" >/dev/null 2>&1 && pwd)"

export device=avaota
echo ----- Remove checkrelease folder
cd /tmp
rm -rf checkrelease-$device

## Build NuttX
function build_nuttx {

  ## Go to NuttX Folder
  pushd ../nuttx

  ## Build NuttX
  make -j

  ## Return to previous folder
  popd
}

## Build Apps Filesystem
function build_apps {

  ## Go to NuttX Folder
  pushd ../nuttx

  ## Build Apps Filesystem
  make -j export
  pushd ../apps
  ./tools/mkimport.sh -z -x ../nuttx/nuttx-export-*.tar.gz
  make -j import
  popd

  ## Return to previous folder
  popd
}

neofetch

echo ----- download staged artifacts. Check their signature and hashes.
mkdir checkrelease-$device
cd checkrelease-$device
url=https://dist.apache.org/repos/dist/dev/nuttx/$release-$candidate/
for file in \
  apache-nuttx-$release.tar.gz.asc \
  apache-nuttx-$release.tar.gz.sha512 \
  apache-nuttx-$release.tar.gz \
  apache-nuttx-apps-$release.tar.gz.asc \
  apache-nuttx-apps-$release.tar.gz.sha512 \
  apache-nuttx-apps-$release.tar.gz
do
  wget $url/$file
done
## Previously: wget -r -nH --cut-dirs=100 --no-parent https://dist.apache.org/repos/dist/dev/nuttx/$release-$candidate/

## To import the keys: wget https://dist.apache.org/repos/dist/dev/nuttx/KEYS && gpg --import KEYS
## To trust the keys: gpg --edit-key 9208D2E4B800D66F749AD4E94137A71698C5E4DB
## Then enter "trust" and "5"
echo '----- [RM] verify the reported signature ("gpg: Good signature from ...")'
gpg --verify apache-nuttx-$release.tar.gz.asc apache-nuttx-$release.tar.gz
gpg --verify apache-nuttx-apps-$release.tar.gz.asc apache-nuttx-apps-$release.tar.gz

## For Linux: Use "sha512sum" instead of "shasum -a 512"
echo '----- [RM] verify the reported hashes:'
shasum -a 512 -c apache-nuttx-$release.tar.gz.sha512
shasum -a 512 -c apache-nuttx-apps-$release.tar.gz.sha512

echo ----- extract src bundle
tar -xf apache-nuttx-$release.tar.gz
tar -xf apache-nuttx-apps-$release.tar.gz

echo ----- verify the existence of LICENSE, NOTICE, README.md files in the extracted source bundle in BOTH apps and nuttx
ls -l nuttx/LICENSE
ls -l nuttx/NOTICE
ls -l nuttx/README.md
ls -l apps/LICENSE
ls -l apps/NOTICE
ls -l apps/README.md

echo ----- Build Targets
cd nuttx

echo '===== Avaota-A1 Compiler'
aarch64-none-elf-gcc -v

echo '===== Avaota-A1 Configuration'
./tools/configure.sh avaota-a1:nsh

echo ----- Build NuttX
build_nuttx

echo ----- Build Apps Filesystem
build_apps

echo ----- Generate Initial RAM Disk
genromfs -f initrd -d ../apps/bin -V "NuttXBootVol"

echo '===== Avaota-A1 Size'
aarch64-none-elf-size nuttx

echo ----- Dump the disassembly to nuttx.S
aarch64-none-elf-objdump \
  --syms --source --reloc --demangle --line-numbers --wide \
  --debugging \
  nuttx \
  >nuttx.S \
  2>&1 \
  &

echo ----- Dump the init disassembly to init.S
aarch64-none-elf-objdump \
  --syms --source --reloc --demangle --line-numbers --wide \
  --debugging \
  ../apps/bin/init \
  >init.S \
  2>&1

echo ----- Copy the config
cp .config nuttx.config

echo ----- Prepare a Padding with 64 KB of zeroes
head -c 65536 /dev/zero >/tmp/nuttx.pad

echo ----- Append Padding and Initial RAM Disk to NuttX Kernel
cat nuttx.bin /tmp/nuttx.pad initrd \
  >Image

## Copy the NuttX Image to MicroSD
scp Image $AVAOTA_SERVER:/tmp/Image
ssh $AVAOTA_SERVER ls -l /tmp/Image
ssh $AVAOTA_SERVER sudo /home/user/copy-image.sh

## Run the NuttX Test
echo '===== Avaota-A1 NSH Info and Free'
cd $script_dir
expect ./avaota.exp

echo ----- TODO: Verify hash from uname
