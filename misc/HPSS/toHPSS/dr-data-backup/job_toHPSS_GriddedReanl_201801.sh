#!/bin/bash
#SBATCH -J paper2hpss_nrtnoda
#SBATCH -A chem-var
#SBATCH -n 1
#SBATCH -t 23:59:00
#SBATCH -p service
#SBATCH -D ./
#SBATCH -o /scratch2/BMC/gsd-fv3-dev/MAPP_2018/bhuang/JEDI-2020/JEDI-FV3/miscLog/toHPSS_GriddedReanl_201801.txt
#SBATCH -e /scratch2/BMC/gsd-fv3-dev/MAPP_2018/bhuang/JEDI-2020/JEDI-FV3/miscLog/toHPSS_GriddedReanl_201801.txt

module load hpss
set -x

SDATE=2019010100  #2018070100  #2018010300 # 2023110100  #2023070100  #2023010100
EDATE=2019043018  #2018123118  #2018063018 #2024011800  #2023103100  #2023063000
CINC=6
NARAOLD="NARA-2.0"
NARANEW="NARA-V1.1"
EXPNAME="AeroReanl_EP4_AeroDA_YesSPEEnKF_YesSfcanl_v14_0dz0dp_41M_C96_201801"
NODAEXPNAME="AeroReanl_EP4_FreeRun_NoSPE_YesSfcanl_v14_0dz0dp_1M_C96_201801"
HERADIR=/scratch2/BMC/gsd-fv3-dev/bhuang/expRuns/UFS-Aerosols_RETcyc/AeroReanl/
HPSSDIR=/BMC/fim/5year/MAPP_2018/bhuang/UFS-Aerosols-expRuns/UFS-Aerosols_RETcyc/AeroReanl/${NARANEW}
HERADATADIR=${HERADIR}/${EXPNAME}/dr-data-backup/GriddedReanl
NODAHERADATADIR=${HERADIR}/${NODAEXPNAME}/dr-data-backup/GriddedReanl
HPSSDATADIR=${HPSSDIR}/
TMPDATADIR=${HERADATADIR}/tmp-mv2hpss
FAILEDREC=${HERADATADIR}/tmp-mv2hpss/Record.Failed
NDATE=/scratch2/NCEPDEV/nwprod/NCEPLIBS/utils/prod_util.v1.1.0/exec/ndate
NRM="/bin/rm -rf"
NCP="/bin/cp -r"

[[ ! -d ${TMPDATADIR} ]] && mkdir -p ${TMPDATADIR}

CDATE=${SDATE}
while [ ${CDATE} -le ${EDATE} ]; do
    echo ${CDATE}
    CY=${CDATE:0:4}
    CM=${CDATE:4:2}
    CD=${CDATE:6:2}
    CH=${CDATE:8:2}

    HPSSFILEDIR=${HPSSDATADIR}/${CY}/${CY}${CM}/${CY}${CM}${CD}

echo "hsi "mkdir -p ${HPSSFILEDIR}""
hsi "mkdir -p ${HPSSFILEDIR}"
ERR=$?
if [ ${ERR} != 0 ]; then
    echo ${CDATE}  >> ${FAILEDREC}
    exit 100
fi

    ICNT=0
    HERAFILEDIR=${HERADATADIR}/${CY}/${CY}${CM}/${CY}${CM}${CD}
    NODAHERAFILEDIR=${NODAHERADATADIR}/${CY}/${CY}${CM}/${CY}${CM}${CD}
    TMPFILEDIR=${TMPDATADIR}/${CDATE}
    mkdir -p ${TMPFILEDIR}
    HPSSFILE=${NARANEW}_${CDATE}.tar 
    cd ${HERAFILEDIR}
    FILES=$(ls ${NARAOLD}_*_${CDATE}*.nc)
    for FILE in ${FILES}; do
        FILENEW=$(echo "${FILE}" | sed -e "s/${NARAOLD}/${NARANEW}/g")
	echo ${FILE}
	echo ${FILENEW}
        ${NCP} ${FILE} ${TMPFILEDIR}/${FILENEW}
        ERR=$?
        ICNT=$((${ICNT}+${ERR}))
    done
    ${NCP} NativeGridReanl_${CDATE} ${TMPFILEDIR}/
    ERR=$?
    ICNT=$((${ICNT}+${ERR}))
    if [ ${ICNT} -ne 0 ]; then
        echo ${CDATE}  >> ${FAILEDREC}
        exit ${ICNT}
    fi
    cd ${TMPFILEDIR}
    #htar -P -cvf ${HPSSFILE} *
    tar -cvf ${TMPDATADIR}/${HPSSFILE} *
    ERR=$?
    ICNT=$((${ICNT}+${ERR}))
    if [ ${ERR} -ne 0 ]; then
        echo ${CDATE}  >> ${FAILEDREC}
        exit 100
    fi
    hsi "put ${TMPDATADIR}/${HPSSFILE} : ${HPSSFILEDIR}/${HPSSFILE}"
    ERR=$?
    ICNT=$((${ICNT}+${ERR}))
    if [ ${ICNT} -ne 0 ]; then
        echo ${CDATE}  >> ${FAILEDREC}
        exit ${ICNT}
    else
        echo "-------${CDATE} ${FIELD} completed and move on-------"
        ${NRM} ${HERAFILEDIR}/fv3_aeros_fv_tracer_*${CDATE}_*.nc
        ${NRM} ${HERAFILEDIR}/${NARAOLD}_AEROS_${CDATE}_*.nc
        ${NRM} ${HERAFILEDIR}/NativeGridReanl_${CDATE}/${CY}${CM}${CD}.${CH}0000.fv_core.res.tile?.nc
        ${NRM} ${HERAFILEDIR}/NativeGridReanl_${CDATE}/${CY}${CM}${CD}.${CH}0000.fv_tracer_aeroanl.res.tile?.nc
        ${NRM} ${TMPFILEDIR}
        ${NRM} ${TMPDATADIR}/${HPSSFILE}
        ${NRM} ${NODAHERAFILEDIR}/fv3_aeros_fv_tracer_${CDATE}_*.nc
    fi
    
    CDATE=$(${NDATE} ${CINC} ${CDATE})
done

exit ${ERR}
