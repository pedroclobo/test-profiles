#!/bin/sh
tar -xvf zstd-1.5.4.tar.gz
cd zstd-1.5.4
make -j $NUM_CPU_CORES
echo $? > ~/install-exit-status
cd ~
TASKSET="taskset -c 1"
cat > compress-zstd <<EOT
#!/bin/sh
$TASKSET ./zstd-1.5.4/zstd -T\$NUM_CPU_CORES \$@ silesia.tar > \$LOG_FILE 2>&1
sed -i -e "s/\r/\n/g" \$LOG_FILE
EOT
chmod +x compress-zstd
