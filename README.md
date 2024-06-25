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
sudo apt install -y expect

## Optional: For TinyEMU
sudo apt install -y emscripten

## To import the keys: 
wget https://dist.apache.org/repos/dist/dev/nuttx/KEYS && gpg --import KEYS
## To trust the keys: 
gpg --edit-key 9208D2E4B800D66F749AD4E94137A71698C5E4DB
## Then enter "trust" and "5"

## Optional: For VSCode
sudo snap install code
```
