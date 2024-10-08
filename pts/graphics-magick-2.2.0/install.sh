#!/bin/sh
tar -xf GraphicsMagick-1.3.43.tar.xz
mkdir $HOME/gm_
cd GraphicsMagick-1.3.43/
LDFLAGS="-L$HOME/gm_/lib" CPPFLAGS="-I$HOME/gm_/include" ./configure --without-perl --prefix=$HOME/gm_ --without-png > /dev/null
if [ $OS_TYPE = "BSD" ]
then
	gmake -j $NUM_CPU_CORES
else
	make -j $NUM_CPU_CORES
fi
echo $? > ~/install-exit-status
if [ $OS_TYPE = "BSD" ]
then
	gmake install
else
	make install
fi

TASKSET="taskset -c 1"

cd ~
rm -rf GraphicsMagick-1.3.43/
rm -rf gm_/share/doc/GraphicsMagick/
rm -rf gm_/share/man/
./gm_/bin/gm convert sample-photo-mars.jpg input.mpc
echo "#!/bin/sh
OMP_NUM_THREADS=\$NUM_CPU_CORES $TASKSET ./gm_/bin/gm benchmark -duration 60 convert input.mpc \$@ null: > \$LOG_FILE 2>&1
echo \$? > ~/test-exit-status" > graphics-magick
chmod +x graphics-magick
