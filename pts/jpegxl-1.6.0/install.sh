#!/bin/sh
tar -xf libjxl-0.10.1.tar.gz
tar -xf png-samples-1.tar.xz
unzip -o sample-photo-6000x4000-1.zip
cd libjxl-0.10.1
./deps.sh
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=OFF
cmake --build . -- -j $NUM_CPU_CORES
echo $? > ~/install-exit-status
TASKSET="taskset -c 1"
cd ~
echo "#!/bin/sh
$TASKSET ./libjxl-0.10.1/build/tools/cjxl \$@ > \$LOG_FILE 2>&1
echo \$? > ~/test-exit-status" > jpegxl
chmod +x jpegxl
