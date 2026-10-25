#!/bin/sh

tar -xf LuaJIT-20190110.tar.xz
cd LuaJIT-Git
# Remove gcc as default compiler. BSD sed needs a suffix after -i.
sed -i.orig 's/^CC=/#CC=/g' src/Makefile && rm -f src/Makefile.orig
make -j $NUM_CPU_CORES
echo $? > ~/install-exit-status

cd ~
echo "#!/bin/sh
$PIN_CMD ./LuaJIT-Git/src/luajit scimark.lua -large > \$LOG_FILE 2>&1" > luajit
chmod +x luajit
