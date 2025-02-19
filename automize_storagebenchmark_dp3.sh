#!/bin/bash
#automize DP3 storage benchmark for local disk, BS-Cinder and CephFS-Manila
#sudo -i

# BS - cinder (/mnt/scratch)
cd /mnt/scratch
DAY=`date +"%d/%m/%Y"`
TIME=`date +"%H:%M"`
echo "CINDER: TODAY IS $DAY AND THE CURRENT TIME IS $TIME UTC !!!!!!!!!"
make
rm -f  dp3-new-benchmark-singularity.sif
sleep 600

# CephFS - Manila (/mnt/scratch1)
cd /mnt/scratch1
DAY=`date +"%d/%m/%Y"`
TIME=`date +"%H:%M"`
echo "MANILA: TODAY is $DAY AND THE CURRENT TIME $TIME UTC !!!!!!!!!"
make
rm  -f dp3-new-benchmark-singularity.sif
sleep 600


#local disk (/root)
#cd /home/amendoza
#DAY=`date +"%d/%m/%Y"`
#TIME=`date +"%H:%M"`
#echo "LOCAL-DISK: TODAY is $DAY AND THE CURRENT TIME $TIME UTC !!!!!!!!!"
#make
#rm -f  dp3-new-benchmark-singularity.sif
#sleep 600
