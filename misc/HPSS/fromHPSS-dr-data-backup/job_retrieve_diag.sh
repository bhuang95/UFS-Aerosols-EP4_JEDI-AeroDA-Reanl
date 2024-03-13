#! /usr/bin/env bash

CURDIR=$(pwd)
TOPHERA="/scratch2/BMC/gsd-fv3-dev/bhuang/expRuns/UFS-Aerosols_RETcyc/AeroReanl/"
TOPHPSS="/BMC/fim/5year/MAPP_2018/bhuang/UFS-Aerosols-expRuns/UFS-Aerosols_RETcyc/AeroReanl"
SDATE=2020072400
EDATE=2020072400
EXPS="
AeroReanl_EP4_AeroDA_YesSPEEnKF_YesSfcanl_v15_0dz0dp_41M_C96_202007
"

RUNSCRIPT="retrieve_diag.sh"
RUNCMD="/apps/slurm/default/bin/sbatch ${RUNSCRIPT}"
for EXP in ${EXPS}; do
    if ( echo ${EXP} | grep AeroDA ); then
        AERODA=YES
        ENSRUN=YES
    else
        AERODA=NO
        ENSRUN=NO
    fi
    HERADIR=${TOPHERA}/${EXP}/dr-data-backup/
    HPSSDIR=${TOPHPSS}/${EXP}/dr-data-backup/
    TMP=${HERADIR}/HPSS2HERA
    [[ ! -d ${TMP} ]] && mkdir -p ${TMP}
    cd ${TMP}
    cp -r ${CURDIR}/${RUNSCRIPT} ./
cat << EOF > config_hpss2hera
HERAEXP=${HERADIR}
HPSSEXP=${HPSSDIR}

SDATE=${SDATE}
EDATE=${EDATE}
CYCINC=6

AERODA=${AERODA}
ENSRUN=${ENSRUN}
EOF
${RUNCMD}
ERR=$?
done
