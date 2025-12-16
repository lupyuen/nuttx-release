#!/usr/bin/env bash
## Validate NuttX Release for Ox64 BL808
## Based on https://cwiki.apache.org/confluence/display/NUTTX/Validating+a+staged+Release
## Sample Output: https://gist.github.com/lupyuen/d211428dc43d85b8ec1fd803275e9f26
## clear && ~/nuttx-release/release.sh ox64
echo ----- Validate NuttX Release for Ox64 BL808
echo release=$release
echo candidate=$candidate
echo hash=$hash
echo Now running https://github.com/lupyuen/nuttx-release/blob/main/release-ox64.sh

## TODO: Update PATH for xPack riscv-none-elf-gcc
## export PATH="$HOME/xpack-riscv-none-elf-gcc-13.2.0-2/bin:$PATH"

set -e  ## Exit when any command fails
set -x  ## Echo commands

export device=ox64
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
## For macOS: Use "shasum -a 512" instead of "sha512sum"
echo '----- [RM] verify the reported hashes:'
sha512sum -c apache-nuttx-$release.tar.gz.sha512
sha512sum -c apache-nuttx-apps-$release.tar.gz.sha512
## shasum -a 512 -c apache-nuttx-$release.tar.gz.sha512
## shasum -a 512 -c apache-nuttx-apps-$release.tar.gz.sha512

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

echo '===== Ox64 BL808 Compiler'
riscv-none-elf-gcc -v

echo '===== Ox64 BL808 Configuration'
./tools/configure.sh ox64:nsh

echo ----- Build NuttX
build_nuttx

echo ----- Build Apps Filesystem
build_apps

echo ----- Generate Initial RAM Disk
genromfs -f initrd -d ../apps/bin -V "NuttXBootVol"

echo '===== Ox64 BL808 Size'
riscv-none-elf-size nuttx

echo ----- Export the Binary Image to nuttx.bin
riscv-none-elf-objcopy \
  -O binary \
  nuttx \
  nuttx.bin

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

echo ----- Wait for microSD
microsd=/media/luppy/43F4-25ED
set +x  #  Don't echo commands
echo "***** Insert microSD into computer"
while : ; do
  if [ -d "$microsd" ]
  then
    break
  fi
  sleep 1
done
sleep 1
set -x  #  Echo commands

echo ----- Copy to microSD
cp Image "$microsd/"
ls -l "$microsd/Image"

echo ----- Unmount microSD
umount "$microsd"
## For macOS: diskutil unmountDisk /dev/disk2
## TODO: Verify that /dev/disk2 is microSD

echo ----- Wait for USB Serial to be connected
## sudo usermod -a -G dialout $USER
usbserial=/dev/ttyUSB0
set +x  #  Don't echo commands
echo "***** Connect Ox64 BL808 to USB Serial"
while : ; do
  if [ -c "$usbserial" ]
  then
    break
  fi
  sleep 1
done
set -x  #  Echo commands

echo ----- Run the firmware
echo Insert microSD into Ox64 BL808, power on Ox64, run "uname -a" and "free".
echo Press Enter to begin...
read

echo '===== Ox64 BL808 NSH Info and Free'
screen "$usbserial" 2000000
screen "$usbserial" 2000000
screen "$usbserial" 2000000
screen "$usbserial" 2000000
screen "$usbserial" 2000000
screen "$usbserial" 2000000
screen "$usbserial" 2000000
screen "$usbserial" 2000000
screen "$usbserial" 2000000
screen "$usbserial" 2000000
screen "$usbserial" 2000000
screen "$usbserial" 2000000
screen "$usbserial" 2000000
screen "$usbserial" 2000000
screen "$usbserial" 2000000
screen "$usbserial" 2000000
screen "$usbserial" 2000000
screen "$usbserial" 2000000
screen "$usbserial" 2000000
screen "$usbserial" 2000000

echo ----- TODO: Verify hash from uname
