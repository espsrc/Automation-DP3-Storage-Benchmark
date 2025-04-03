#!/bin/bash
#automize DP3 storage benchmark for local disk, BS-Cinder and CephFS-Manila

#local disk (/home/amendoza)
####cd /home/amendoza
#local disk (/root)
cd /root
DAY=`date +"%d/%m/%Y"`
TIME=`date +"%H:%M:%S"`
echo "LOCAL-DISK: TODAY is $DAY AND THE CURRENT TIME IS $TIME UTC !!!!!!!!!"
make
rm -f  dp3-new-benchmark-singularity.sif
TIME=`date +"%H:%M:%S"`
echo "DONE $TIME UTC !!!!!!!!!"
sleep 600
