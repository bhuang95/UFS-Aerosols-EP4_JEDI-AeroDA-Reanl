#!/bin/bash

SCRIPTDIR="/home/Bo.Huang/JEDI-2020/UFS-Aerosols_RETcyc/UFS-Aerosols-EP4_JEDI-AeroDA-Reanl/misc/hpssVIIRS/fromHPSS"
TOPDIR="/scratch1/NCEPDEV/rstprod/Bo.Huang/HpssViirsAod/"

RETAOD="job_retrieve_aod_noaaviirs.sh"
PREPAOD="job_prepaod_noaaviirs_v1_v2_v3.sh"

STS=("2019120100")
EDS=("2019123118")
#STS=("2020010100" "2020020100" "2020030100" "2020040100" "2020050100" "2020060100")
#EDS=("2020013118" "2020022918" "2020033118" "2020043018" "2020053118" "2020063018")
#STS=("2022010100" "2022020100" "2022030100" "2022040100" "2022050100" "2022060100" "2022070100" "2022080100" "2022090100" "2022100100" "2022110100" "2022120100")
#EDS=("2022013118" "2022022818" "2022033118" "2022043018" "2022053118" "2022063018" "2022073118" "2022083118" "2022093018" "2022103118" "2022113018" "2022123118")

for i in ${!STS[@]}; do
    ST=${STS[$i]}
    ED=${EDS[$i]}
    STDIR=${TOPDIR}/Prep_VIIRSAOD_${ST}_${ED}
    [[ ! -d ${STDIR} ]] && mkdir -p ${STDIR}
    cd ${STDIR} 
    cp -r ${SCRIPTDIR}/${RETAOD} ./
    cp -r ${SCRIPTDIR}/${PREPAOD} ./
    echo ${ST} > SDAY.info
    echo ${ED} > EDAY.info
/apps/slurm/default/bin/sbatch job_retrieve_aod_noaaviirs.sh
done
