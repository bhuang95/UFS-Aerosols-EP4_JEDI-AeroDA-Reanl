#!/bin/bash

SRCDIR=/scratch2/BMC/gsd-fv3-dev/bhuang/expRuns/UFS-Aerosols_RETcyc/AeroReanl/AeroReanl_EP4_FreeRun_NoSPE_YesSfcanl_v14_0dz0dp_1M_C96_201801/dr-data/HERA2HPSS

cd ${SRCDIR}
FILES=$(ls record.failed_HERA2HPSS-*)

for FILE in ${FILES}; do
    CDATE=${FILE:(-10)}
    cd ${SRCDIR}/${CDATE}
    if ( grep 'exit code 1:0' hera2hpss.out ); then
	echo ${CDATE}
        sbatch sbatch_arch2hpss_ret.sh
    fi
done
