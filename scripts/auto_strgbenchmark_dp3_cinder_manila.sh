#!/bin/bash
#automize DP3 storage benchmark for local disk, BS-Cinder and CephFS-Manila

# BS - cinder (/mnt/scratch)
cd /mnt/scratch
DAY=`date +"%d/%m/%Y"`
TIME=`date +"%H:%M:%S"`
echo "CINDER: TODAY IS $DAY AND THE CURRENT TIME IS $TIME UTC !!!!!!!!!"
make
rm -f  dp3-new-benchmark-singularity.sif
TIME=`date +"%H:%M:%S"`
echo "DONE $TIME UTC !!!!!!!!!"
sleep 600

# CephFS - Manila (/mnt/scratch1)
cd /mnt/scratch1
DAY=`date +"%d/%m/%Y"`
TIME=`date +"%H:%M:%S"`
echo "MANILA: TODAY is $DAY AND THE CURRENT TIME IS $TIME UTC !!!!!!!!!"
make
rm  -f dp3-new-benchmark-singularity.sif
TIME=`date +"%H:%M:%S"`
echo "DONE $TIME UTC !!!!!!!!!"
sleep 600
