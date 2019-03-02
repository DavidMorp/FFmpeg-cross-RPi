#!/bin/bash
echo Cross-compiling FFmpeg for Raspbian https://trac.ffmpeg.org/wiki/CompilationGuide/RaspberryPi

echo Preparing the environment
apt install texinfo pkg-config autoconf bison flex unzip help2man gawk libtool-bin ncurses-dev

echo Building the crosstool-ng
clone https://github.com/crosstool-ng/crosstool-ng
cd crosstool-ng/
./bootstrap
autoreconf
./configure --prefix=/opt/cross
make
sudo make install
export PATH=$PATH:/opt/cross/bin

echo Building the toolchain
mkdir /home/david/ctng
cd /home/david/ctng
./ct-ng arm-unknown-linux-gnueabi
ct-ng menuconfig

echo You will now set up the options. Refer to docs
read -p "Press enter to continue"
ct-ng build

export PATH=$PATH:/opt/cross/x-tools/arm-unknown-linux-gnueabi/bin
export CCPREFIX="/opt/cross/x-tools/arm-unknown-linux-gnueabi/bin/arm-unknown-linux-gnueabi-"


echo Compiling libaacplus
mkdir /home/david/ffmpeg/source
cd /home/david/ffmpeg/source
wget http://tipok.org.ua/downloads/media/aacplus/libaacplus/libaacplus-2.0.2.tar.gz
tar -xzf libaacplus-2.0.2.tar.gz
cd libaacplus-2.0.2
./autogen.sh --with-parameter-expansion-string-replace-capable-shell=/bin/bash --host=arm-unknown-linux-gnueabi --enable-static --prefix=/home/david/ffmpeg/arm
make
make install

#echo Other libraries...
#cd /home/david/ffmpeg/source
#cd my_other_library
#CFLAGS="-I/home/david/ffmpeg/arm/include" LDFLAGS="-L/home/david/ffmpeg/arm/libs" ./configure ... --prefix=...
#make
#make install

echo Compiling libx264
cd /home/david/ffmpeg/source
git clone git://git.videolan.org/x264
cd x264
./configure --host=arm-unknown-linux-gnueabi --enable-static --cross-prefix=${CCPREFIX} --prefix=/home/david/ffmpeg/arm --extra-cflags='-march=armv6' --extra-ldflags='-march=armv6'
make
make install

echo Compiling ALSA library
cd /home/david/ffmpeg/source
wget http://mirrors.zerg.biz/alsa/lib/alsa-lib-1.0.25.tar.bz2
tar xjf alsa-lib-1.0.25.tar.bz2
cd alsa-lib-1.0.25/
./configure --host=arm-unknown-linux-gnueabi --prefix=/home/david/ffmpeg/source/arm
make
make install

echo Compiling FFmpeg
cd /home/david/ffmpeg/source
git clone git://source.ffmpeg.org/ffmpeg.git
cd ffmpeg
./configure --enable-cross-compile --cross-prefix=${CCPREFIX} --arch=armel --target-os=linux --prefix=/home/david/ffmpeg/arm --enable-gpl --enable-libx264 --enable-nonfree --enable-libaacplus --enable-mmal --enable-omx --enable-omx-rpi --extra-cflags="-I/home/david/ffmpeg/arm/include" --extra-ldflags="-L/home/david/ffmpeg/arm/lib" --extra-libs=-ldl
make
make install
