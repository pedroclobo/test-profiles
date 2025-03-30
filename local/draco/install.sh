#!/bin/sh
tar -xf draco-1.5.6.tar.gz
cd draco-1.5.6
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release ..
make -j $NUM_CPU_CORES
echo $? > ~/install-exit-status
cd ~
unzip -o church-facade-ply.zip
mv Church\ façade.ply draco-1.5.6/build/church.ply
cd ~
echo "#!/bin/sh
cd draco-1.5.6/build
$PIN_CMD ./draco_encoder \$@ -o out.drc -cl 10 -qp 16 > \$LOG_FILE 2>&1
echo \$? > ~/test-exit-status" > draco
chmod +x draco
