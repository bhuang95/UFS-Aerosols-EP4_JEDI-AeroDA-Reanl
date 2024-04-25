#! /usr/bin/env bash

CURDIR=$(pwd)
TOPHERA="/scratch2/BMC/gsd-fv3-dev/bhuang/expRuns/UFS-Aerosols_RETcyc/AeroReanl/"
TOPHPSS="/BMC/fim/5year/MAPP_2018/bhuang/UFS-Aerosols-expRuns/UFS-Aerosols_RETcyc/AeroReanl"
SDATE=2020070100 #2018020206  #2018010206  #2018030100  #2020080100 #2020073012  #2020072406
EDATE=2020103118 #2018043018  #2018043018  #2020083118 #2020082518  #2020073118
EXPS="
AeroReanl_EP4_AeroDA_YesSPEEnKF_YesSfcanl_v15_0dz0dp_41M_C96_202007
"
#AeroReanl_EP4_AeroDA_YesSPEEnKF_YesSfcanl_v14_0dz0dp_41M_C96_201801
#AeroReanl_EP4_AeroDA_YesSPEEnKF_YesSfcanl_v14_0dz0dp_41M_C96_201801
#AeroReanl_EP4_FreeRun_NoSPE_YesSfcanl_v15_0dz0dp_1M_C96_202007
#AeroReanl_EP4_AeroDA_YesSPEEnKF_YesSfcanl_v15_0dz0dp_41M_C96_202007
#AeroReanl_EP4_FreeRun_NoSPE_YesSfcanl_v14_0dz0dp_1M_C96_201801

#RUNSCRIPT="retrieve_diag_6tilesOnly.sh"
RUNSCRIPT="retrieve_diag_6tiles.sh"
RUNCMD="/apps/slurm_hera/default/bin/sbatch ${RUNSCRIPT}"
for EXP in ${EXPS}; do
    if ( echo ${EXP} | grep AeroDA ); then
        AERODA=YES
        ENSRUN=YES
	NGANL=YES
    else
        AERODA=NO
        ENSRUN=NO
	NGANL=NO
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

NGANL=${NGANL}
EOF
${RUNCMD}
ERR=$?
done
