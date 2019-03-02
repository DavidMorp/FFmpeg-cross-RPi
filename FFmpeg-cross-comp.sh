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
mkdir /home/david/sources


echo Compiling libaacplus
cd /home/david/sources
wget http://tipok.org.ua/downloads/media/aacplus/libaacplus/libaacplus-2.0.2.tar.gz
tar -xzf libaacplus-2.0.2.tar.gz
cd libaacplus-2.0.2
./autogen.sh --with-parameter-expansion-string-replace-capable-shell=/bin/bash --host=arm-unknown-linux-gnueabi --enable-static --prefix=/home/david/arm-bin
make
make install

#echo Other libraries...
#cd /home/david/sources
#cd my_other_library
#CFLAGS="-I/home/david/arm-bin/include" LDFLAGS="-L/home/david/arm-bin/libs" ./configure ... --prefix=...
#make
#make install

echo Compiling mmal
cd /home/david/sources
git clone https://aur.archlinux.org/ffmpeg-mmal.git
cd ffmpeg-mmal
./configure --host=arm-unknown-linux-gnueabi --enable-static --cross-prefix=${CCPREFIX} --prefix=/home/david/arm-bin --extra-cflags='-march=armv6' --extra-ldflags='-march=armv6'
make
make install

echo Compiling libx264
cd /home/david/sources
git clone git://git.videolan.org/x264
cd x264
./configure --host=arm-unknown-linux-gnueabi --enable-static --cross-prefix=${CCPREFIX} --prefix=/home/david/arm-bin --extra-cflags='-march=armv6' --extra-ldflags='-march=armv6'
make
make install

echo Compiling ALSA library
cd /home/david/sources
wget http://mirrors.zerg.biz/alsa/lib/alsa-lib-1.0.25.tar.bz2
tar xjf alsa-lib-1.0.25.tar.bz2
cd alsa-lib-1.0.25/
./configure --host=arm-unknown-linux-gnueabi --prefix=/home/david/arm-bin
make
make install

echo Compiling FFmpeg FULL
cd /home/david/sources
git clone git://source.ffmpeg.org/ffmpeg.git
cd ffmpeg
./configure --enable-cross-compile --cross-prefix=${CCPREFIX} --arch=armel --target-os=linux --prefix=/home/david/arm-bin --enable-gpl --enable-libx264 --enable-nonfree --enable-libaacplus --enable-mmal --enable-omx --enable-omx-rpi --extra-cflags="-I/home/david/arm-bin/include" --extra-ldflags="-L/home/david/arm-bin/lib" --extra-libs=-ldl
make
make install

echo Compiling FFmpeg RoadApplePi
cd /home/david/sources
git clone git://source.ffmpeg.org/ffmpeg.git
cd ffmpeg
./configure --enable-cross-compile --cross-prefix=${CCPREFIX} --arch=armel --target-os=linux --prefix=/home/david/arm-bin --enable-gpl --enable-nonfree --enable-mmal --enable-omx --enable-omx-rpi --extra-cflags="-I/home/david/arm-bin/include" --extra-ldflags="-L/home/david/arm-bin/lib" --extra-libs=-ldl
make
make install
