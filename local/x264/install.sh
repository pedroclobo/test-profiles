#!/bin/sh

mkdir x264_/
tar -xjf x264-git-20220222.tar.bz2
cd x264-master

PATH="$HOME/x264_/bin:$PATH" ./configure --prefix=$HOME/x264_/ --disable-opencl --enable-lto --enable-pic --enable-shared
PATH="$HOME/x264_/bin:$PATH" make -j $NUM_CPU_CORES
make install
echo $? > ~/install-exit-status
cd ~
rm -rf x264-master

7z x Bosphorus_1920x1080_120fps_420_8bit_YUV_Y4M.7z -aoa

echo "#!/bin/sh
./x264_/bin/x264 -o /dev/null \$@ > \$LOG_FILE 2>&1
echo \$? > ~/test-exit-status" > x264
chmod +x x264
