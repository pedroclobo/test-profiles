#!/bin/sh

unzip -o crafty-25.2.zip

export LDFLAGS="$LDFLAGS -pthread -lstdc++"

# Custom Makefile for Clang
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

cd ~

echo "#!/bin/sh
$PIN_CMD ./crafty \$@ > \$LOG_FILE 2>&1
echo \$? > ~/test-exit-status" > crafty-benchmark
chmod +x crafty-benchmark
