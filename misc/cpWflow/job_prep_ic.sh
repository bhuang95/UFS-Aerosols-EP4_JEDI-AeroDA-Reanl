#!/bin/bash

CYCDIR=/scratch2/BMC/gsd-fv3-dev/MAPP_2018/bhuang/JEDI-2020/JEDI-FV3/expRuns/UFS-Aerosols_RETcyc/RET_EP4_SpinUp_C96_202005/dr-data/20200526/06
NMEM=20
INPUTDIR="model_data/atmos/input"

IMEM=1
while [ ${IMEM} -le ${NMEM} ]; do
    MEMSTR=mem`printf %03d ${IMEM}`
    MEMDIR=${CYCDIR}/${MEMSTR}
    echo "${MEMDIR}"
    cd ${MEMDIR}
    rm -rf *.rc *.nc input.nml  model_configure	nems.configure	RESTART
    mkdir -p ${INPUTDIR}
    mv INPUT/* ${INPUTDIR}/
    IMEM=$((IMEM+1))
done
