#!/bin/sh
tar -xf aircrack-ng-1.7.tar.gz
cd aircrack-ng-1.7
# macOS ships a libpcre.pc in /usr/lib/pkgconfig but no PCRE headers, so
# configure enables PCRE and the build fails. Only search Homebrew's
# pkg-config files there.
if [ "$(uname -s)" = Darwin ] && command -v brew > /dev/null; then
  export PKG_CONFIG_LIBDIR="$(brew --prefix)/lib/pkgconfig:$(brew --prefix)/share/pkgconfig"
  # easside-ng and wesside-ng use zlib's crc32 without linking zlib.
  export LIBS="$LIBS -lz"
fi
./autogen.sh
make -j $NUM_CPU_CORES
echo $? > ~/install-exit-status

cd ~
echo "#!/bin/sh
cd aircrack-ng-1.7
$PIN_CMD ./aircrack-ng -p \$NUM_CPU_CORES \$@  2>&1 | tr '\\r' '\\n' | awk -v max=0 '{if(\$1>max){max=\$1}}END{print max \" k/s\"}' > \$LOG_FILE
echo \$? > ~/test-exit-status" > aircrack-ng
chmod +x aircrack-ng
