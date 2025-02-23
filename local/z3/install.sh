#!/bin/sh
tar -xvf z3_solver-4.14.0.0.tar.gz
pushd z3_solver-4.14.0.0/core
CC=$CC CXX=$CXX python scripts/mk_make.py
python3 scripts/mk_make.py
cd build
make -j$NUM_CPU_CORES
popd
echo "#!/bin/sh
$PIN_CMD ./z3_solver-4.14.0.0/core/build/z3 \$1 > \$LOG_FILE 2>&1
echo \$? > ~/test-exit-status" > ~/z3
chmod +x ~/z3
