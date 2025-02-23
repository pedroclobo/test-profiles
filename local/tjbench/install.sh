#!/bin/sh

unzip -o jpeg-test-1.zip
tar -xzvf libjpeg-turbo-2.1.0.tar.gz
cd libjpeg-turbo-2.1.0
mkdir build
cd build
cmake ..
make -j $NUM_CPU_CORES
echo $? > ~/install-exit-status

cd ~

echo "#!/bin/sh
cd libjpeg-turbo-2.1.0/build
$PIN_CMD ./tjbench ../../jpeg-test-1.JPG -benchtime 20 -warmup 5 -nowrite > \$LOG_FILE
echo \$? > ~/test-exit-status" > tjbench
chmod +x tjbench
