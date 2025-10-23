#!/bin/sh
tar -xf libjxl-0.10.1.tar.gz
unzip -o sample-photo-6000x4000-1.zip
cd libjxl-0.10.1
./deps.sh
sed -i '/#elif defined(USING_AVX_F16C)/,/^#else/{/^#else/!d}' third_party/skcms/src/Transform_inl.h
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=OFF
cmake --build . -- -j $NUM_CPU_CORES
echo $? > ~/install-exit-status
cd ~
echo "#!/bin/sh
$PIN_CMD ./libjxl-0.10.1/build/tools/cjxl \$@ > \$LOG_FILE 2>&1
echo \$? > ~/test-exit-status" > jpegxl
chmod +x jpegxl
