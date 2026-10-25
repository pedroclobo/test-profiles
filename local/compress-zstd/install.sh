#!/bin/sh
tar -xvf zstd-1.5.4.tar.gz
cd zstd-1.5.4
make -j $NUM_CPU_CORES
echo $? > ~/install-exit-status
cd ~
cat > compress-zstd <<EOT
#!/bin/sh
$PIN_CMD ./zstd-1.5.4/zstd -T\$NUM_CPU_CORES \$@ silesia.tar > \$LOG_FILE 2>&1
tr "\r" "\n" < \$LOG_FILE > \$LOG_FILE.tmp && mv \$LOG_FILE.tmp \$LOG_FILE
EOT
chmod +x compress-zstd
