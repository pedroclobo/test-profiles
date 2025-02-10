#!/bin/sh
unzip -o c7cacb14f5ed20aca56a52f1ac0cd4d5035084b6.zip
cd john-c7cacb14f5ed20aca56a52f1ac0cd4d5035084b6/src/
./configure --disable-native-tests --disable-opencl
make -j $NUM_CPU_CORES
echo $? > ~/install-exit-status

TASKSET="taskset -c 1"

cd ~/
echo "#!/bin/sh
cd john-c7cacb14f5ed20aca56a52f1ac0cd4d5035084b6/run/
$TASKSET ./john \$@ > \$LOG_FILE 2>&1
echo \$? > ~/test-exit-status" > john-the-ripper
chmod +x john-the-ripper
