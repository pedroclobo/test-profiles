#!/bin/sh
tar -zxvf gutenberg-science.tar.gz
tar -xf espeak-ng-1.51.tar.gz
cd espeak-ng-1.51
./autogen.sh
./configure --prefix=$HOME/espeak_
sed -i "s/CC = gcc/CC = $CC/g" Makefile
make # build seems to have problems with multiple cores
echo $? > ~/install-exit-status
make install

TASKSET="taskset -c 1"

cd ~
rm -rf espeak-ng-1.51
echo "#!/bin/sh
cd espeak_/bin/
LD_LIBRARY_PATH=\$HOME/espeak_/lib/:\$LD_LIBRARY_PATH $TASKSET ./espeak-ng -f ~/gutenberg-science.txt -w espeak-output 2>&1
echo \$? > ~/test-exit-status" > espeak
chmod +x espeak
