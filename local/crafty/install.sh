#!/bin/sh

unzip -o crafty-25.2.zip

# Crafty is x86-only in three places: the SMP spinlock in lock.h and the
# lowest-set-bit helper in tbprobe.c are x86 assembly, and the build passes
# -mpopcnt. Elsewhere, use the __sync and __builtin_ctzll equivalents.
case "$(uname -m)" in
  x86_64|amd64) POPCNT="-mpopcnt" ;;
  *)
    POPCNT=""
    sed -i.orig 's/__asm__("bsfq %1, %0": "=r"(idx):"rm"(b));/idx = __builtin_ctzll(b);/' tbprobe.c
    cat > lock.h <<'EOF'
#if (CPUS > 1)
static void __inline__ Pause() {
#  if defined(__aarch64__)
  __asm__ __volatile__("yield");
#  endif
}
#  define LockInit(p)           (p=0)
#  define LockFree(p)           (p=0)
#  define Lock(p)               do { while (__sync_lock_test_and_set(&(p), 1)) while (p) Pause(); } while (0)
#  define Unlock(p)             __sync_lock_release(&(p))
#  define lock_t                volatile int
#else
#  define LockInit(p)
#  define LockFree(p)
#  define Lock(p)
#  define Unlock(p)
#  define lock_t                volatile int
#endif
EOF
    ;;
esac

# macOS links C++ code against libc++.
if [ "$(uname -s)" = Darwin ]; then CXXLIB="-lc++"; else CXXLIB="-lstdc++"; fi

export LDFLAGS="$LDFLAGS -pthread $CXXLIB"

# Custom Makefile for Clang
cat <<EOF >> Makefile
my-clang:
	\$(MAKE) -j target=UNIX \\
		CC=$CC \\
		opt='-DSYZYGY -DTEST -DCPUS=$NUM_CPU_CORES' \\
		CFLAGS='-Wall -Wno-array-bounds -pipe $CFLAGS $POPCNT' \\
		LDFLAGS='\$(LDFLAGS) -fprofile-use $CXXLIB' \\
		crafty-make
EOF
# -i.orig: BSD sed needs a backup suffix.
sed -i.orig "s/\$(MAKE) -j unix-clang/\$(MAKE) my-clang/" Makefile
sed -i.orig 's/-j / /g' Makefile
make -j $NUM_CPU_CORES

echo $? > ~/install-exit-status

cd ~

echo "#!/bin/sh
$PIN_CMD ./crafty \$@ > \$LOG_FILE 2>&1
echo \$? > ~/test-exit-status" > crafty-benchmark
chmod +x crafty-benchmark
