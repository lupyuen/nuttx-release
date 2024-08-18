# Scripts for Apache NuttX RTOS Release Testing

Apache NuttX Release Testing for Milk-V Duo S, Ox64 BL808, Star64 JH7110, PinePhone:

```bash
## TODO: Update `release.sh` and enter the release / candidate / hash:
## export release=12.5.1
## export candidate=RC0
## export hash=9e8753d625

## Run the Release Test Script for Milk-V Duo S, Ox64 BL808, Star64 JH7110, PinePhone:
./release.sh milkvduos
./release.sh ox64
./release.sh star64
./release.sh pinephone
```

To prepare Ubuntu for NuttX Release Testing:

```bash
## Grant access to /dev/tty*
sudo usermod -a -G dialout $USER

## Install NuttX prerequisities
sudo apt install -y git neofetch screen curl
sudo apt install -y \
  bison flex gettext texinfo libncurses5-dev libncursesw5-dev xxd \
  gperf automake libtool pkg-config build-essential gperf genromfs \
  libgmp-dev libmpc-dev libmpfr-dev libisl-dev binutils-dev libelf-dev \
  libexpat-dev gcc-multilib g++-multilib picocom u-boot-tools util-linux
sudo apt install -y kconfig-frontends
sudo apt install -y expect gh

## Install xPack GCC Toolchain for RISC-V (Linux x64)
wget https://github.com/xpack-dev-tools/riscv-none-elf-gcc-xpack/releases/download/v13.2.0-2/xpack-riscv-none-elf-gcc-13.2.0-2-linux-x64.tar.gz
tar xf xpack-riscv-none-elf-gcc-13.2.0-2-linux-x64.tar.gz
export PATH=$PWD/xpack-riscv-none-elf-gcc-13.2.0-2/bin:$PATH
riscv-none-elf-gcc -v
## Should show: `gcc version 13.2.0 (xPack GNU RISC-V Embedded GCC x86_64)`

wget https://github.com/xpack-dev-tools/riscv-none-elf-gcc-xpack/releases/download/v12.3.0-1/xpack-riscv-none-elf-gcc-12.3.0-1-linux-arm64.tar.gz
$ tar xf xpack-riscv-none-elf-gcc-12.3.0-1-linux-arm64.tar.gz
$ export PATH=$PWD/xpack-riscv-none-elf-gcc-12.3.0-1/bin:$PATH

## Optional: For TinyEMU
sudo apt install -y emscripten

## To import the keys: 
wget https://dist.apache.org/repos/dist/dev/nuttx/KEYS && gpg --import KEYS
## To trust the keys: 
gpg --edit-key 9208D2E4B800D66F749AD4E94137A71698C5E4DB
## Then enter "trust" and "5"

## Optional: For VSCode
sudo snap install code

## Tested on Ubuntu 24.04 LTS x86_64
$ neofetch
            .-/+oossssoo+/-.               luppy@luppy-macbook-ubuntu
        `:+ssssssssssssssssss+:`           --------------------------
      -+ssssssssssssssssssyyssss+-         OS: Ubuntu 24.04 LTS x86_64
    .ossssssssssssssssssdMMMNysssso.       Host: MacBookPro10,1 1.0
   /ssssssssssshdmmNNmmyNMMMMhssssss/      Kernel: 6.8.0-40-generic
  +ssssssssshmydMMMMMMMNddddyssssssss+     Uptime: 20 mins
 /sssssssshNMMMyhhyyyyhmNMMMNhssssssss/    Packages: 2447 (dpkg), 26 (snap)
.ssssssssdMMMNhsssssssssshNMMMdssssssss.   Shell: bash 5.2.21
+sssshhhyNMMNyssssssssssssyNMMMysssssss+   Resolution: 1920x1080
ossyNMMMNyMMhsssssssssssssshmmmhssssssso   Terminal: /dev/pts/2
ossyNMMMNyMMhsssssssssssssshmmmhssssssso   CPU: Intel i7-3820QM (8) @ 3.700GHz
+sssshhhyNMMNyssssssssssssyNMMMysssssss+   GPU: NVIDIA GeForce GT 650M Mac Edition
.ssssssssdMMMNhsssssssssshNMMMdssssssss.   GPU: Intel 3rd Gen Core processor Graphics Controller
 /sssssssshNMMMyhhyyyyhdNMMMNhssssssss/    Memory: 4210MiB / 15898MiB
  +sssssssssdmydMMMMMMMMddddyssssssss+
   /ssssssssssshdmNNNNmyNMMMMhssssss/
    .ossssssssssssssssssdMMMNysssso.
      -+sssssssssssssssssyyyssss+-
        `:+ssssssssssssssssss+:`
            .-/+oossssoo+/-.
```
