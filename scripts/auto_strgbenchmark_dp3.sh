#!/bin/bash
#automize DP3 storage benchmark for local disk, BS-Cinder and CephFS-Manila


DIA=$(date +%d)
if (( DIA % 2 == 1 )); then
    auto_strgbenchmark_dp3_manila_cinder.sh
else
    auto_strgbenchmark_dp3_local.sh
fi
