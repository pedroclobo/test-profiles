#!/bin/sh

unzip -o jpeg-test-1.zip
tar -xzvf libjpeg-turbo-2.1.0.tar.gz
cd libjpeg-turbo-2.1.0
mkdir build
cd build
cmake ..
if [ "$OS_TYPE" = "BSD" ]
then
	gmake -j $NUM_CPU_CORES
else
	make -j $NUM_CPU_CORES
fi
echo $? > ~/install-exit-status

TASKSET="taskset -c 1"

cd ~

echo "#!/bin/sh
cd libjpeg-turbo-2.1.0/build
$TASKSET ./tjbench ../../jpeg-test-1.JPG -benchtime 20 -warmup 5 -nowrite > \$LOG_FILE
echo \$? > ~/test-exit-status" > tjbench
chmod +x tjbench
