#!/usr/bin/env bash
## Validate NuttX Release for PinePhone
## Based on https://cwiki.apache.org/confluence/display/NUTTX/Validating+a+staged+Release
## Sample Output: https://gist.github.com/lupyuen/5760e0375d44a06b3c730a10614e4d24
## clear && cd /tmp && script /tmp/release-pinephone.log -c ~/nuttx-release/release-pinephone.sh
echo ----- Validate NuttX Release for PinePhone

## TODO: Update PATH for Arm GNU Toolchain aarch64-none-elf
## export PATH="$HOME/arm-gnu-toolchain-13.2.Rel1-x86_64-aarch64-none-elf/bin:$PATH"

echo ----- Remove checkrelease folder
cd /tmp
rm -r checkrelease

set -e  ## Exit when any command fails
set -x  ## Echo commands

## TODO: Update release and candidate
release=12.5.1
candidate=RC0

## Build NuttX
function build_nuttx {

  ## Go to NuttX Folder
  pushd ../nuttx

  ## Build NuttX
  make -j 8

  ## Return to previous folder
  popd
}

neofetch

echo ----- download staged artifacts. Check their signature and hashes.
mkdir checkrelease
cd checkrelease
wget -r -nH --cut-dirs=100 --no-parent https://dist.apache.org/repos/dist/dev/nuttx/$release-$candidate/

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

echo '===== PinePhone Compiler'
aarch64-none-elf-gcc -v

echo '===== PinePhone Configuration'
./tools/configure.sh pinephone:nsh

echo ----- Build NuttX
build_nuttx

echo ----- Copy the config
cp .config nuttx.config

echo ----- Compress the NuttX Image
cp nuttx.bin Image
rm -f Image.gz
gzip Image

echo '===== PinePhone Size'
aarch64-none-elf-size nuttx

echo ----- Dump the disassembly to nuttx.S
aarch64-none-elf-objdump \
  -t -S --demangle --line-numbers --wide \
  nuttx \
  >nuttx.S \
  2>&1 \
  &

echo ----- Wait for microSD
microsd=/media/luppy/A993-6C26
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
cp Image.gz "$microsd/"
ls -l "$microsd/Image.gz"

echo ----- Unmount microSD
umount "$microsd"
## For macOS: diskutil unmountDisk /dev/disk2
## TODO: Verify that /dev/disk2 is microSD

echo ----- Wait for USB Serial to be connected
## sudo usermod -a -G dialout $USER
usbserial=/dev/ttyUSB0
set +x  #  Don't echo commands
echo "***** Insert microSD into PinePhone, connect PinePhone to USB"
while : ; do
  if [ -c "$usbserial" ]
  then
    break
  fi
  sleep 1
done
set -x  #  Echo commands


echo ----- Run the firmware
echo Power on PinePhone, run "uname -a" and "free".
echo Press Enter to begin...
read

echo '===== PinePhone NSH Info and Free'
sudo screen "$usbserial" 115200

echo ----- TODO: Verify hash from uname
