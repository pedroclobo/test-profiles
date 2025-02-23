#!/bin/sh

tar -xzvf fftw-3.3.10.tar.gz
rm -rf fftw-mr
rm -rf fftw-stock

mv fftw-3.3.10 fftw-stock
cp -a fftw-stock fftw-mr

AVX_TUNING=""
if grep avx512 /proc/cpuinfo > /dev/null; then
  AVX_TUNING="$AVX_TUNING --enable-avx512"
fi
if grep avx2 /proc/cpuinfo > /dev/null; then
  AVX_TUNING="$AVX_TUNING --enable-avx2"
fi

cd fftw-mr
./configure --enable-float --enable-sse --enable-threads $AVX_TUNING
make -j $NUM_CPU_JOBS
echo $? > ~/install-exit-status

cd ~/fftw-stock
./configure --enable-threads
make -j $NUM_CPU_JOBS

cd ~/
echo "
#!/bin/sh

$PIN_CMD ./\$@ > \$LOG_FILE 2>&1
echo \$? > ~/test-exit-status
" > fftw

chmod +x fftw

