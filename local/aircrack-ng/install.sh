#!/bin/sh
tar -xf aircrack-ng-1.7.tar.gz
cd aircrack-ng-1.7
./autogen.sh
make -j $NUM_CPU_CORES
echo $? > ~/install-exit-status

cd ~
echo "#!/bin/sh
cd aircrack-ng-1.7
$PIN_CMD ./aircrack-ng -p \$NUM_CPU_CORES \$@  2>&1 | tr '\\r' '\\n' | awk -v max=0 '{if(\$1>max){max=\$1}}END{print max \" k/s\"}' > \$LOG_FILE
echo \$? > ~/test-exit-status" > aircrack-ng
chmod +x aircrack-ng
