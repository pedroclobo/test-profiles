#!/bin/bash
tar xf Stockfish-sf_17.tar.gz
cd Stockfish-sf_17/src/
sed -i "s|@test|@echo|g" Makefile
sed -i "s|CXXFLAGS += -flto=full||g" Makefile
make -j build COMP=$CC COMPCXX=$CXX
echo $? > ~/install-exit-status
cd ~
echo "#!/bin/sh
cd Stockfish-sf_17/src/
$PIN_CMD ./stockfish bench 4096 \$NUM_CPU_CORES 26 > \$LOG_FILE 2>&1
echo \$? > ~/test-exit-status" > stockfish
chmod +x stockfish

