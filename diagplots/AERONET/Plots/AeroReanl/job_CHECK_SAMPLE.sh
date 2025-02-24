#!/bin/bash

RUNDIR=/scratch2/BMC/gsd-fv3-dev/bhuang/expRuns/UFS-Aerosols_RETcyc/AeroReanl/
DAEXP=AeroReanl_EP4_AeroDA_YesSPEEnKF_YesSfcanl_v15_0dz0dp_41M_C96_202007
FREXP=AeroReanl_EP4_FreeRun_NoSPE_YesSfcanl_v15_0dz0dp_1M_C96_202007
SDATE=2020080100  #2020070100
EDATE=2020083118  #2020073118
#DAEXP=AeroReanl_EP4_AeroDA_YesSPEEnKF_YesSfcanl_v14_0dz0dp_41M_C96_201801
#FREXP=AeroReanl_EP4_FreeRun_NoSPE_YesSfcanl_v14_0dz0dp_1M_C96_201801
#SDATE=2018020100  #2018010100
#EDATE=2018022818  #2018013118
CYCINC=6

FILE="AERONET_SOLAR_AOD15*.nc4"

EXPS="
${DAEXP}
${FREXP}
"
NDATE=/scratch2/NCEPDEV/nwprod/NCEPLIBS/utils/prod_util.v1.1.0/exec/ndate

CDATE=${SDATE}
icnt1=0
while [ ${CDATE} -le ${EDATE} ]; do
    icnt1=$((${icnt1}+1))
    CDATE=$(${NDATE} ${CYCINC} ${CDATE})
done

icnt2=$((${icnt1} * 2))

for EXP in ${EXPS}; do
    if [ ${EXP} = ${DAEXP} ]; then
        rcnt=${icnt2}
    else
        rcnt=${icnt1}
    fi
    CDATE=${SDATE}
    tcnt=0
    while [ ${CDATE} -le ${EDATE} ]; do
        CYMD=${CDATE:0:8}
	CH=${CDATE:8:2}
	DATADIR=${RUNDIR}/${EXP}/dr-data-backup/gdas.${CYMD}/${CH}/diag/aod_obs
	cnt=$(ls ${DATADIR}/${FILE} | wc -l)
	tcnt=$((${tcnt} + ${cnt}))
        CDATE=$(${NDATE} ${CYCINC} ${CDATE})
    done # while CDATE -le EDATE
    if [ ${rcnt} -eq ${tcnt} ]; then
        echo "SUCCEEDED: ${EXP}-${SDATE}-${EDATE}-rcnt-${rcnt}-tcnt-${tcnt}"
    else
        echo "FAILED: 	 ${EXP}-${SDATE}-${EDATE}-rcnt-${rcnt}-tcnt-${tcnt}"
    fi
done # EXP
