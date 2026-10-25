#!/bin/sh
tar -xf draco-1.5.6.tar.gz
cd draco-1.5.6
# libc++ no longer includes some standard headers transitively.
add_include() { { echo "#include <$1>"; cat "$2"; } > "$2.tmp" && mv "$2.tmp" "$2"; }
add_include iterator src/draco/compression/point_cloud/algorithms/float_points_tree_encoder.h
add_include algorithm src/draco/io/ply_reader.cc
# Apple's linker has no --start-group/--end-group.
sed -i.orig 's/MATCHES "^Clang|^GNU")/MATCHES "^Clang|^GNU" AND NOT APPLE)/' cmake/draco_targets.cmake
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release ..
make -j $NUM_CPU_CORES
echo $? > ~/install-exit-status
cd ~
unzip -o church-facade-ply.zip
mv Church\ façade.ply draco-1.5.6/build/church.ply
unzip -o lion-statue_ply.zip
mv Lion\ statue_ply/Lion\ statue.ply draco-1.5.6/build/lion.ply
cd ~
echo "#!/bin/sh
cd draco-1.5.6/build
$PIN_CMD ./draco_encoder \$@ -o out.drc -cl 10 -qp 16 > \$LOG_FILE 2>&1
echo \$? > ~/test-exit-status" > draco
chmod +x draco
