#!/bin/sh
tar -xf 7z2405-src.tar.xz
cd CPP/7zip/Bundles/Alone2
make -j $NUM_CPU_CORES -f makefile.gcc
EXIT_STATUS=$?
echo $EXIT_STATUS > ~/install-exit-status
cd ~
echo "#!/bin/sh
$PIN_CMD ./CPP/7zip/Bundles/Alone2/_o/7zz b > \$LOG_FILE 2>&1
echo \$? > ~/test-exit-status" > compress-7zip
chmod +x compress-7zip
