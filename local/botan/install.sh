#!/bin/sh

tar -xf Botan-2.17.3.tar.xz

cd Botan-2.17.3
# libc++ no longer includes some standard headers transitively.
add_include() { { echo "#include <$1>"; cat "$2"; } > "$2.tmp" && mv "$2.tmp" "$2"; }
add_include cstdlib src/lib/compat/sodium/sodium_utils.cpp
add_include exception src/lib/utils/mem_pool/mem_pool.cpp
add_include iterator src/lib/x509/certstor_system_macos/certstor_macos.cpp
python3 ./configure.py
make -j $NUM_CPU_CORES
echo $? > ~/install-exit-status

cd ~
echo "#!/bin/sh
cd Botan-2.17.3
LD_LIBRARY_PATH=.:\$LD_LIBRARY_PATH ./botan speed \$@ > \$LOG_FILE 2>&1
echo \$? > ~/test-exit-status" > botan
chmod +x botan
