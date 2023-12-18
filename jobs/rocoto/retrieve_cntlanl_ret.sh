#!/bin/bash --login
#SBATCH -J hpss2hera
#SBATCH -A chem-var
#SBATCH -n 1
#SBATCH -t 24:00:00
#SBATCH -p service
#SBATCH -D ./
#SBATCH -o ./hpss2hera.out
#SBATCH -e ./hpss2hera.out

set -x
# Back up cycled data to HPSS at ${CDATE}-6 cycle

#source config_hera2hpss
PSLOT=${PSLOT:-"ENKF_AEROSEMIS-ON_STOCHINIT-OFF-201710"}
ROTDIR=${ROTDIR:-"/scratch2/BMC/gsd-fv3-dev/MAPP_2018/bhuang/JEDI-2020/JEDI-FV3/expRuns/UFS-Aerosols_RETcyc/ENKF_AEROSEMIS-ON_STOCHINIT-OFF-201710/dr-data-longfcst"}
CDATE=${CDATE:-"2017100600"}
CYCINTHR=${CYCINTHR:-"06"}
ARCHHPSSDIR=${ARCHHPSSDIR:-"/BMC/fim/5year/MAPP_2018/bhuang/UFS-Aerosols-expRuns/UFS-Aerosols_RETcyc/"}
TMPDIR=${ROTDIR}/

NDATE="/scratch2/NCEPDEV/nwprod/NCEPLIBS/utils/prod_util.v1.1.0/exec/ndate"

module load hpss
#export PATH="/apps/hpss/bin:$PATH"
set -x

NCP="/bin/cp -r"
NMV="/bin/mv -f"
NRM="/bin/rm -rf"
NLN="/bin/ln -sf"

GDATE=$(${NDATE} -${CYCINTHR} ${CDATE})

IDATE=${GDATE}
while [ ${IDATE} -le ${CDATE} ]; do
    IY=${IDATE:0:4}
    IM=${IDATE:4:2}
    ID=${IDATE:6:2}
    IH=${IDATE:8:2}
    IYMD=${IDATE:0:8}

    SRCDIR=${ARCHHPSSDIR}/${PSLOT}/dr-data/${IY}/${IY}${IM}/${IYMD}/
    SRCFILE=${SRCDIR}/gdas.${IDATE}.tar

    TGTDIR=${TMPDIR}/gdas.${IYMD}/${IH}
    [[ ! -d ${TGTDIR} ]] && mkdir -p ${TGTDIR}
    cd ${TGTDIR} 

    if [ ${IDATE} = ${GDATE} ]; then
        htar -xvf ${SRCFILE} atmos/RESTART
        ERR=$?
        [[ ${ERR} -ne 0 ]] && exit ${ERR}
        TGTDIR_ROT=${ROTDIR}/gdas.${IYMD}/${IH}/atmos/RESTART
	[[ -d ${TGTDIR_ROT} ]] && mkdir -p ${TGTDIR_ROT}
	mv ${TGTDIR}/atmos/RESTART/*  ${TGTDIR_ROT}/
        [[ ${ERR} -ne 0 ]] && exit ${ERR}
    elif [ ${IDATE} = ${CDATE} ]; then
        htar -xvf ${SRCFILE} atmos/gdas.t${IH}z.atminc.nc
        ERR=$?
        [[ ${ERR} -ne 0 ]] && exit ${ERR}
        TGTDIR_ROT=${ROTDIR}/gdas.${IYMD}/${IH}/atmos/
	[[ -d ${TGTDIR_ROT} ]] && mkdir -p ${TGTDIR_ROT}
	mv ${TGTDIR}/atmos/gdas.t${IH}z.atminc.nc  ${TGTDIR_ROT}/
        [[ ${ERR} -ne 0 ]] && exit ${ERR}
        
	i=1
	while [ ${i} -le 6 ]; do
            htar -xvf ${SRCFILE} atmos/RESTART/${IYMD}.${IH}0000.sfcanl_data.tile${i}.nc
            ERR=$?
            [[ ${ERR} -ne 0 ]] && exit ${ERR}
	    i=$((i+1))
	done
        TGTDIR_ROT=${ROTDIR}/gdas.${IYMD}/${IH}/atmos/RESTART/
	[[ -d ${TGTDIR_ROT} ]] && mkdir -p ${TGTDIR_ROT}
	mv ${TGTDIR}/atmos/RESTART/${IYMD}.${IH}0000.sfcanl_data*.nc  ${TGTDIR_ROT}/
        [[ ${ERR} -ne 0 ]] && exit ${ERR}
    else
        echo "IDATE not properly defined and exit now"
	exit 100
    fi

    IDATE=$(${NDATE} ${CYCINTHR} ${IDATE})
done

exit ${ERR}
