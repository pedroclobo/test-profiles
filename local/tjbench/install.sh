#!/bin/sh

unzip -o jpeg-test-1.zip
tar -xzvf libjpeg-turbo-2.1.0.tar.gz
cd libjpeg-turbo-2.1.0
mkdir build
cd build
# CMake 4 refuses projects that require a CMake older than 3.5.
cmake -DCMAKE_POLICY_VERSION_MINIMUM=3.5 ..
make -j $NUM_CPU_CORES
echo $? > ~/install-exit-status

cd ~

echo "#!/bin/sh
cd libjpeg-turbo-2.1.0/build
$PIN_CMD ./tjbench ../../jpeg-test-1.JPG -benchtime 20 -warmup 5 -nowrite > \$LOG_FILE
echo \$? > ~/test-exit-status" > tjbench
chmod +x tjbench
