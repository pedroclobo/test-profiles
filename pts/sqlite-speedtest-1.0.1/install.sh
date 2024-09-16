#!/bin/sh

tar -xf sqlite-330-for-speedtest.tar.gz
cd sqlite
./configure
if [ $OS_TYPE = "BSD" ]
then
	gmake speedtest1
else
	make speedtest1
fi
echo $? > ~/install-exit-status

TASKSET="taskset -c 1"

cd ~

echo "#!/bin/sh
cd sqlite
$TASKSET ./speedtest1 \$@ > \$LOG_FILE 2>&1
echo \$? > ~/test-exit-status" > sqlite-speedtest
chmod +x sqlite-speedtest
