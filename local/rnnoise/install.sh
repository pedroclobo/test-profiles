#!/bin/sh
tar -xf sample-audio-long-1.tar.xz
tar -xf rnnoise-0.2.tar.gz
cd rnnoise-0.2
./autogen.sh
BUILD_OPTIONS=""
if [ -r /proc/cpuinfo ] && grep -q avx /proc/cpuinfo; then
  BUILD_OPTIONS="--enable-x86-rtcd "
fi
# The NEON code (arm64) includes os_support.h, which the 0.2 release
# tarball lacks. Provide the macros it uses.
if [ ! -f src/os_support.h ]; then
cat > src/os_support.h <<'EOF'
#ifndef OS_SUPPORT_H
#define OS_SUPPORT_H
#include <string.h>
#ifndef OPUS_INLINE
#define OPUS_INLINE inline
#endif
#define OPUS_CLEAR(dst, n) (memset((dst), 0, (n)*sizeof(*(dst))))
#endif
EOF
fi
./configure $BUILD_OPTIONS
make -j $NUM_CPU_CORES
echo $? > ~/install-exit-status
cd ~
echo "#!/bin/sh
$PIN_CMD ./rnnoise-0.2/examples/rnnoise_demo  \$1 out.raw
echo \$? > ~/test-exit-status" > rnnoise
chmod +x rnnoise
