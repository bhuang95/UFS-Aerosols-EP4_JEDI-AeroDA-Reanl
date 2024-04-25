#!/bin/bash --login
#SBATCH -J retaod
#SBATCH -A gsd-fv3-dev
#SBATCH -n 1
#SBATCH --mem=5g
#SBATCH -t 24:00:00
#SBATCH -p service
#SBATCH -D ./
#SBATCH -o retaod.out
#SBATCH -e retaod.out

module load hpss
set -x

#SCRIPTDIR="/home/Bo.Huang/JEDI-2020/UFS-Aerosols_RETcyc/UFS-Aerosols-EP4_JEDI-AeroDA-Reanl/misc/hpssVIIRS/fromHPSS"
#cd ${SCRIPTDIR}
TOPDIR="/scratch1/NCEPDEV/rstprod/Bo.Huang/HpssViirsAod/"
SDATE=$(cat SDAY.info)
EDATE=$(cat EDAY.info)
EXP="Prep_VIIRSAOD_${SDATE}_${EDATE}"
#SDATE=
#EDATE=
EXPDIR=${TOPDIR}/${EXP}
#SDATE=2019120100  #2019110100  #2019092000
#EDATE=2019123118  #2019113018  #2019103100
#echo ${SDATE} > SDAY_${EXP}.info
#echo ${EDATE} > EDAY_${EXP}.info
CYCINC=24
AODSAT="npp"

NDATE="/scratch2/NCEPDEV/nwprod/NCEPLIBS/utils/prod_util.v1.1.0/exec/ndate"

SDATE=$(${NDATE} -${CYCINC} ${SDATE})
IDATE=${SDATE}
while [ ${IDATE} -le ${EDATE} ]; do
    ECNT=0
    IY=${IDATE:0:4}
    IM=${IDATE:4:2}
    ID=${IDATE:6:2}
    HPSSDIR=/BMC/fdr/Permanent/${IY}/${IM}/${ID}/data/sat/nesdis/viirs/aod/conus
    HERADIR=${EXPDIR}/${IDATE}
    HPSSFILE=${HPSSDIR}/${IDATE}00.zip

    [[ -d ${HERADIR} ]] && rm -rf  ${HERADIR}
    mkdir -p ${HERADIR}
    cd ${HERADIR}

    hsi "get ${HPSSFILE}"
    ERR=$?
    ECNT=$((${ECNT}+${ERR}))
    unzip ${IDATE}00.zip "*_${AODSAT}_*.nc"
    ERR=$?
    ECNT=$((${ECNT}+${ERR}))
    if [ ${ECNT} -ne 0 ]; then
        echo "There is an error and exit now"
	exit ${ECNT}
    else
	rm -rf  ${HERADIR}/${IDATE}00.zip
    fi
    IDATE=$(${NDATE} ${CYCINC} ${IDATE})
done

cd ${EXPDIR}
echo "SUCCESSFUL" > ${EXPDIR}/${SDATE}_${EDATE}.retaod
/apps/slurm/default/bin/sbatch job_prepaod_noaaviirs_v1_v2_v3.sh
exit ${ECNT}


