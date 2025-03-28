#!/bin/sh
mkdir $HOME/flac_
tar -xJf flac-1.5.0.tar.xz

cd flac-1.5.0
./configure --prefix=$HOME/flac_ --disable-doxygen-docs
make -j $NUM_CPU_CORES
echo $? > ~/install-exit-status
make install

cd ~
rm -rf flac-1.5.0
rm -rf flac_/share/
echo "#!/bin/sh
for i in \$(seq 1 10); do
	./flac_/bin/flac --best  --threads=\$NUM_CPU_CORES large-wav-audio-file-speech-sample.wav -f -o output 2>&1
done
echo \$? > ~/test-exit-status" > encode-flac
chmod +x encode-flac
