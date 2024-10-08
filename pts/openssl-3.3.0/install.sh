#!/bin/sh
tar -xf openssl-3.3.0.tar.gz
cd openssl-3.3.0
./config no-zlib
make -j $NUM_CPU_CORES
echo $? > ~/install-exit-status

TASKSET="taskset -c 1"

cd ~
echo "#!/bin/sh
cd openssl-3.3.0
LD_LIBRARY_PATH=.:\$LD_LIBRARY_PATH $TASKSET ./apps/openssl speed -multi \$NUM_CPU_CORES -seconds 30 \$@ > \$LOG_FILE 2>&1
echo \$? > ~/test-exit-status" > openssl
chmod +x openssl
