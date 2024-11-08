#!/bin/sh

unzip -o crafty-25.2.zip

export LDFLAGS="$LDFLAGS -pthread -lstdc++"
# sed -i ".orig" -e 's/-j /-j4 /g' Makefile

cat <<EOF >> Makefile
my-clang:
	\$(MAKE) -j target=UNIX \\
		CC=clang \\
		opt='-DSYZYGY -DTEST -DCPUS=4' \\
		CFLAGS='-Wall -Wno-array-bounds -pipe $CFLAGS -mpopcnt' \\
		LDFLAGS='\$(LDFLAGS) -fprofile-use -lstdc++' \\
		crafty-make
EOF

sed -i "s/\$(MAKE) -j unix-clang/\$(MAKE) my-clang/" Makefile

sed -i 's/-j / /g' Makefile
make -j $NUM_CPU_CORES

echo $? > ~/install-exit-status

TASKSET="taskset -c 1"

cd ~

echo "#!/bin/sh
$TASKSET ./crafty \$@ > \$LOG_FILE 2>&1
echo \$? > ~/test-exit-status" > crafty-benchmark
chmod +x crafty-benchmark
