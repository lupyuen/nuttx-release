#!/usr/bin/env bash
## Validate NuttX Release for Milk-V Duo S
## Based on https://cwiki.apache.org/confluence/display/NUTTX/Validating+a+staged+Release
## Sample Output: https://gist.github.com/lupyuen/d211428dc43d85b8ec1fd803275e9f26
## clear && ~/nuttx-release/release.sh milkvduos
echo ----- Validate NuttX Release for Milk-V Duo S
echo release=$release
echo candidate=$candidate
echo hash=$hash
echo https://github.com/lupyuen/nuttx-release/blob/main/release-milkvduos.sh

## TODO: Update PATH
export PATH="$HOME/xpack-riscv-none-elf-gcc-13.2.0-2/bin:$PATH"

echo ----- Remove checkrelease folder
cd /tmp
rm -r checkrelease

set -e  ## Exit when any command fails
set -x  ## Echo commands

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

echo '===== Milk-V Duo S Compiler'
riscv-none-elf-gcc -v

echo '===== Milk-V Duo S Configuration'
./tools/configure.sh milkv_duos:nsh

echo ----- Build NuttX
build_nuttx

echo ----- Build Apps Filesystem
build_apps

echo ----- Generate Initial RAM Disk
genromfs -f initrd -d ../apps/bin -V "NuttXBootVol"

echo '===== Milk-V Duo S Size'
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
scp cv181x_milkv_duos_sd.dtb tftpserver:/tftpboot/cv181x_milkv_duos_sd.dtb
scp Image tftpserver:/tftpboot/Image-sg2000
ssh tftpserver ls -l /tftpboot/Image-sg2000

echo ----- Wait for USB Serial to be connected
set +x  #  Don't echo commands
echo "***** Connect Milk-V Duo S to USB Serial"
while : ; do
  if [ -c "/dev/tty.usbserial-0001" ]
  then
    break
  fi
  sleep 1
done
set -x  #  Echo commands

echo ----- Run the firmware
echo Start TFTP Server, power on Milk-V Duo S, run "uname -a" and "free".
echo Press Enter to begin...
read

## Get the Home Assistant Token, copied from http://localhost:8123/profile/security
## token=xxxx
set +x  ##  Disable echo
. $HOME/home-assistant-token.sh
set -x  ##  Enable echo

set +x  ##  Disable echo
echo "----- Power Off the SBC"
curl \
    -X POST \
    -H "Authorization: Bearer $token" \
    -H "Content-Type: application/json" \
    -d '{"entity_id": "automation.sg2000_power_off"}' \
    http://localhost:8123/api/services/automation/trigger
set -x  ##  Enable echo

set +x  ##  Disable echo
echo "----- Power On the SBC"
curl \
    -X POST \
    -H "Authorization: Bearer $token" \
    -H "Content-Type: application/json" \
    -d '{"entity_id": "automation.sg2000_power_on"}' \
    http://localhost:8123/api/services/automation/trigger
set -x  ##  Enable echo

echo '===== Milk-V Duo S NSH Info and Free'
screen /dev/tty.usbserial-0001 115200

set +x  ##  Disable echo
echo "----- Power Off the SBC"
curl \
    -X POST \
    -H "Authorization: Bearer $token" \
    -H "Content-Type: application/json" \
    -d '{"entity_id": "automation.sg2000_power_off"}' \
    http://localhost:8123/api/services/automation/trigger
set -x  ##  Enable echo

echo ----- TODO: Verify hash from uname
