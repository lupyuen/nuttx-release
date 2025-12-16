#!/usr/bin/env bash
## Validate NuttX Release for Oz64 SG2000
## Based on https://cwiki.apache.org/confluence/display/NUTTX/Validating+a+staged+Release
## Sample Output: https://gist.github.com/lupyuen/441db1042582bf8d4699793b31a22c57
## clear && ~/nuttx-release/release.sh oz64
echo ----- Validate NuttX Release for Oz64 SG2000
echo release=$release
echo candidate=$candidate
echo hash=$hash
echo Now running https://github.com/lupyuen/nuttx-release/blob/main/release-oz64.sh

set -e  ## Exit when any command fails
set -x  ## Echo commands

## Server that controls Oz64 SG2000. And the TFTP Server.
export OZ64_SERVER=tftpserver
export TFTP_SERVER=tftpserver

## Get the Script Directory
script_path="${BASH_SOURCE}"
script_dir="$(cd -P "$(dirname -- "${script_path}")" >/dev/null 2>&1 && pwd)"

export device=oz64
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

## For Linux: Use "shasum -a 512" instead of "sha512sum"
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

echo '===== Oz64 SG2000 Compiler'
riscv-none-elf-gcc -v

echo '===== Oz64 SG2000 Configuration'
./tools/configure.sh milkv_duos:nsh

echo ----- Build NuttX
build_nuttx

echo ----- Build Apps Filesystem
build_apps

echo ----- Generate Initial RAM Disk
genromfs -f initrd -d ../apps/bin -V "NuttXBootVol"

echo '===== Oz64 SG2000 Size'
riscv-none-elf-size nuttx

echo ----- Dump the disassembly to nuttx.S
riscv-none-elf-objdump \
  --syms --source --reloc --demangle --line-numbers --wide \
  --debugging \
  nuttx \
  >nuttx.S \
  2>&1 \
  &

echo ----- Dump the init disassembly to init.S
riscv-none-elf-objdump \
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

echo ----- Download the Device Tree
wget https://github.com/lupyuen2/wip-nuttx/releases/download/sg2000-1/cv181x_milkv_duos_sd.dtb

echo ----- Copy NuttX Binary Image and Device Tree to TFTP Server
scp cv181x_milkv_duos_sd.dtb $TFTP_SERVER:/tftpboot/cv181x_milkv_duos_sd.dtb
scp Image $TFTP_SERVER:/tftpboot/Image-sg2000
ssh $TFTP_SERVER ls -l /tftpboot/Image-sg2000

## Run the NuttX Test
echo '===== Oz64 SG2000 NSH Info and Free'
cd $script_dir
expect ./oz64.exp

echo ----- TODO: Verify hash from uname
