#!/bin/sh

tar -xzvf fftw-3.3.10.tar.gz
rm -rf fftw-mr
rm -rf fftw-stock

mv fftw-3.3.10 fftw-stock
cp -a fftw-stock fftw-mr

# SIMD codelets for this CPU: SSE/AVX on x86, NEON on arm64.
case "$(uname -m)" in
  x86_64|amd64) SIMD="--enable-sse" ;;
  arm64|aarch64) SIMD="--enable-neon" ;;
  *) SIMD="" ;;
esac
if [ -r /proc/cpuinfo ] && grep -q avx512 /proc/cpuinfo; then
  SIMD="$SIMD --enable-avx512"
fi
if [ -r /proc/cpuinfo ] && grep -q avx2 /proc/cpuinfo; then
  SIMD="$SIMD --enable-avx2"
fi

cd fftw-mr
./configure --enable-float --enable-threads $SIMD
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

