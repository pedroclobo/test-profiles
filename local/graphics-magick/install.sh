#!/bin/sh
tar -xf GraphicsMagick-1.3.43.tar.xz
mkdir $HOME/gm_
cd GraphicsMagick-1.3.43/
LDFLAGS="-L$HOME/gm_/lib" CPPFLAGS="-I$HOME/gm_/include" ./configure --without-perl --prefix=$HOME/gm_ --without-png > /dev/null
make -j $NUM_CPU_CORES
echo $? > ~/install-exit-status
make install
cd ~
rm -rf GraphicsMagick-1.3.43/
rm -rf gm_/share/doc/GraphicsMagick/
rm -rf gm_/share/man/
./gm_/bin/gm convert sample-photo-mars.jpg input.mpc
echo "#!/bin/sh
OMP_NUM_THREADS=\$NUM_CPU_CORES $PIN_CMD ./gm_/bin/gm benchmark -duration 60 convert input.mpc \$@ null: > \$LOG_FILE 2>&1
echo \$? > ~/test-exit-status" > graphics-magick
chmod +x graphics-magick
