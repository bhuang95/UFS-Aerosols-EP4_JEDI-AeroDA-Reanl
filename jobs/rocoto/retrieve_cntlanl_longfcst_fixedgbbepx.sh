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
EXP_PERT_GBBEPX=${EXP_PERT_GBBEPX:-"/BMC/fim/5year/MAPP_2018/bhuang/UFS-Aerosols-expRuns/UFS-Aerosols_RETcyc/RET_EP4_AeroDA_YesSPEEnKF_YesSfcanl_v15_0dz0dp_41M_C96_202006/dr-data-longfcst-pertgbbepx/"}
GBBDIR_NRT=${GBBDIR_NRT:-"/scratch1/BMC/gsd-fv3-dev/MAPP_2018/bhuang/JEDI-2020/JEDI-FV3/NRTdata_UFS-Aerosols/gocart_emissions//nexus/GBBEPx_v004/"}
SFCANL_RST=${SFCANL_RST:-"YES"}
FHMAX=${FHMAX:-"120"}
TMPDIR=${ROTDIR}/

NDATE="/scratch2/NCEPDEV/nwprod/NCEPLIBS/utils/prod_util.v1.1.0/exec/ndate"
FHMAX=$((${FHMAX}+24))

module load hpss
module load nco
#export PATH="/apps/hpss/bin:$PATH"
set -x

NCP="/bin/cp -r"
NMV="/bin/mv -f"
NRM="/bin/rm -rf"
NLN="/bin/ln -sf"

GDATE=$(${NDATE} -${CYCINTHR} ${CDATE})

CY=${CDATE:0:4}
CM=${CDATE:4:2}
CD=${CDATE:6:2}
CH=${CDATE:8:2}
CYMD=${CDATE:0:8}

GY=${GDATE:0:4}
GM=${GDATE:4:2}
GD=${GDATE:6:2}
GH=${GDATE:8:2}
GYMD=${GDATE:0:8}

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
        RETDIR=model_data/atmos/restart
        htar -xvf ${SRCFILE} ${RETDIR}
        ERR=$?
        [[ ${ERR} -ne 0 ]] && exit ${ERR}
        #TGTDIR_ROT=${ROTDIR}/gdas.${IYMD}/${IH}/${RETDIR}
	#[[ -d ${TGTDIR_ROT} ]] && mkdir -p ${TGTDIR_ROT}
	#mv ${TGTDIR}/${RETDIR}/*  ${TGTDIR_ROT}/
        #[[ ${ERR} -ne 0 ]] && exit ${ERR}

	RETDIR=model_data/atmos/restart/pertEmis/pert_GBBEPx
	#PERTGBBFILE_HPSS=${EXP_PERT_GBBEPX}/${CY}/${CY}${CM}/${CYMD}/gdas.longfcst.${CDATE}.pertEmis.InRstDir${GDATE}.tar
	#if [ -d ${RETDIR}/pertEmis ]; then
	#   echo "${RETDIR}/pertEmis"
	#   ${NRM} -rf ${RETDIR}/pertEmis
	#fi

	if [ ! -d ${RETDIR} ]; then
	    mkdir -p ${RETDIR}
	fi
	cd ${RETDIR}
	#htar -xvf ${PERTGBBFILE_HPSS}
        if [ ${CH} -lt 12 ]; then
            GBBFILE_ORIG=${GBBDIR_NRT}/GBBEPx_all01GRID.emissions_v004_${GYMD}.nc
            GBBFILE_PERT=GBBEPx_all01GRID.emissions_v004_${GYMD}.nc
	    ${NCP} ${GBBFILE_ORIG} ${GBBFILE_PERT}
	fi
        GBBFILE_ORIG=${GBBDIR_NRT}/GBBEPx_all01GRID.emissions_v004_${CYMD}.nc
	FHR=0
	while [ ${FHR} -le ${FHMAX} ]; do
	    PDATE=$(${NDATE} ${FHR} ${CDATE})
            PY=${PDATE:0:4}
            PM=${PDATE:4:2}
            PD=${PDATE:6:2}
            PYMD=${PDATE:0:8}
            GBBFILE_PERT=GBBEPx_all01GRID.emissions_v004_${PYMD}.nc
	    TIME_PERT="hours since ${PY}-${PM}-${PD} 12:00:00"
	    ${NCP} ${GBBFILE_ORIG} ${GBBFILE_PERT}
	    ncatted -O -a units,time,m,c,"${TIME_PERT}" ${GBBFILE_PERT}
            ERR=$?
            [[ ${ERR} -ne 0 ]] && exit ${ERR}
	    FHR=$((${FHR}+24))
	done
    elif [ ${IDATE} = ${CDATE} ]; then
        RETDIR=analysis/atmos
        htar -xvf ${SRCFILE} ${RETDIR}/gdas.t${IH}z.atminc.nc
        ERR=$?
        [[ ${ERR} -ne 0 ]] && exit ${ERR}
        #TGTDIR_ROT=${ROTDIR}/gdas.${IYMD}/${IH}/${RETDIR}
	#[[ -d ${TGTDIR_ROT} ]] && mkdir -p ${TGTDIR_ROT}
	#mv ${TGTDIR}/${RETDIR}/gdas.t${IH}z.atminc.nc  ${TGTDIR_ROT}/
        #[[ ${ERR} -ne 0 ]] && exit ${ERR}
        
	#if [ ${SFCANL_RST} = "YES" ]; then
	#	
	#    RETDIR=model_data/atmos/restart
	#    i=1
	#    while [ ${i} -le 6 ]; do
        #        htar -xvf ${SRCFILE} ${RETDIR}/${IYMD}.${IH}0000.sfc_data_com_sfcanl.tile${i}.nc
        #        ERR=$?
        #        [[ ${ERR} -ne 0 ]] && exit ${ERR}
	#        i=$((i+1))
	#    done
        #    TGTDIR_ROT=${ROTDIR}/gdas.${IYMD}/${IH}/${RETDIR}
	#    [[ -d ${TGTDIR_ROT} ]] && mkdir -p ${TGTDIR_ROT}
	#    mv ${TGTDIR}/${RETDIR}/${IYMD}.${IH}0000.sfc_data_com_sfcanl.tile?.nc  ${TGTDIR_ROT}/
        #    [[ ${ERR} -ne 0 ]] && exit ${ERR}
	#fi
    else
        echo "IDATE not properly defined and exit now"
        exit 100
    fi

    IDATE=$(${NDATE} ${CYCINTHR} ${IDATE})
done

exit ${ERR}
