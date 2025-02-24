#!/bin/bash --login
#SBATCH -J hera2hpss
#SBATCH -A chem-var
#SBATCH -n 1
#SBATCH -t 24:00:00
#SBATCH -p service
#SBATCH --mem=5g
#SBATCH -D ./
#SBATCH -o ./hera2hpss.out
#SBATCH -e ./hera2hpss.out

set -x
# Back up cycled data to HPSS at ${CDATE}-6 cycle

source config_hpss2hera

NDATE="/scratch2/NCEPDEV/nwprod/NCEPLIBS/utils/prod_util.v1.1.0/exec/ndate"

module load hpss
#export PATH="/apps/hpss/bin:$PATH"
set -x

NCP="/bin/cp -r"
NMV="/bin/mv -f"
NRM="/bin/rm -rf"
NLN="/bin/ln -sf"

CDATE=${SDATE}
while [ ${CDATE} -le ${EDATE} ]; do
    ICNT=0
    CY=${CDATE:0:4}
    CM=${CDATE:4:2}
    CD=${CDATE:6:2}
    CH=${CDATE:8:2}
    CYMD=${CDATE:0:8}
    CDATE_P6=$(${NDATE} ${CYCINC} ${CDATE})
    CY_P6=${CDATE_P6:0:4}
    CM_P6=${CDATE_P6:4:2}
    CD_P6=${CDATE_P6:6:2}
    CH_P6=${CDATE_P6:8:2}
    CYMD_P6=${CDATE_P6:0:8}

    if [ ${ENSRUN} = "YES" ]; then
        HPSSDIR=${HPSSEXP}/${CY}/${CY}${CM}/${CYMD}/
	HPSSFILE=enkfgdas.${CDATE}.diag.tar
        HERADIR_ENKF=${HERAEXP}/enkfgdas.${CYMD}/${CH}
 
        [[ ! -d ${HERADIR_ENKF} ]] && mkdir -p ${HERADIR_ENKF}
        cd ${HERADIR_ENKF}
        hsi "get ${HPSSDIR}/${HPSSFILE}"
        ERR=$?
        ICNT=$((${ICNT}+${ERR}))

        tar -xvf ${HPSSFILE}
        ERR=$?
        ICNT=$((${ICNT}+${ERR}))
    fi

    HPSSDIR=${HPSSEXP}/${CY}/${CY}${CM}/${CYMD}
    HPSSFILE=gdas.${CDATE}.diag.tar
    HERADIR=${HERAEXP}/gdas.${CYMD}/${CH}
 
    [[ ! -d ${HERADIR} ]] && mkdir -p ${HERADIR}
    cd ${HERADIR}
    hsi "get ${HPSSDIR}/${HPSSFILE}"
    ERR=$?
    ICNT=$((${ICNT}+${ERR}))

    tar -xvf ${HPSSFILE}
    ERR=$?
    ICNT=$((${ICNT}+${ERR}))

    # Copy gridded reanalysis files
    DIAGDIR=${HERADIR}/diag/
    REANLDIR=${HERAEXP}/GriddedReanl/${CY}/${CY}${CM}/${CYMD}
    [[ ! -d ${REANLDIR} ]] && mkdir -p ${REANLDIR}

    ${NMV} ${DIAGDIR}/aod_grid/fv3_aod_LUTs_fv_tracer*.nc ${REANLDIR}
    ERR=$?
    ICNT=$((${ICNT}+${ERR}))
    ${NMV} ${DIAGDIR}/aeros_grid_ll/fv3_aeros_fv_tracer*.nc ${REANLDIR}
    ERR=$?
    ICNT=$((${ICNT}+${ERR}))
    ${NMV} ${DIAGDIR}/aeros_grid_pll/fv3_aeros_fv_tracer*.nc ${REANLDIR}
    ERR=$?
    ICNT=$((${ICNT}+${ERR}))

    if [ ${AERODA} = "YES" ]; then
        cd ${REANLDIR}
        ANLORG=fv3_aod_LUTs_fv_tracer_aeroanl_${CDATE}_ll.nc
        ANLTGT=NARA-2.0_AOD_${CDATE}.nc
        ${NMV} ${ANLORG} ${ANLTGT}
        ${NLN} ${ANLTGT} ${ANLORG}
        ERR=$?
        ICNT=$((${ICNT}+${ERR}))

        ANLORG=fv3_aeros_fv_tracer_aeroanl_${CDATE}_ll.nc
        ANLTGT=NARA-2.0_AEROS_${CDATE}_LL.nc
        ${NMV} ${ANLORG} ${ANLTGT}
        ${NLN} ${ANLTGT} ${ANLORG}
        ERR=$?
        ICNT=$((${ICNT}+${ERR}))

        ANLORG=fv3_aeros_fv_tracer_aeroanl_${CDATE}_pll.nc
        ANLTGT=NARA-2.0_AEROS_${CDATE}_PLL.nc
        ${NMV} ${ANLORG} ${ANLTGT}
        ${NLN} ${ANLTGT} ${ANLORG}
        ERR=$?
        ICNT=$((${ICNT}+${ERR}))
    fi


    if [ ${NGANL} = "YES" ]; then
        RSTDIR=${HERADIR}/model_data/atmos/restart
	REANLDIR_P6=${HERAEXP}/GriddedReanl/${CY_P6}/${CY_P6}${CM_P6}/${CYMD_P6}
	NGANLDIR=${REANLDIR}/NativeGridReanl_${CDATE}
	NGANLDIR_P6=${REANLDIR_P6}/NativeGridReanl_${CDATE_P6}
	[[ ! -d ${NGANLDIR} ]] && mkdir -p ${NGANLDIR}
	[[ ! -d ${NGANLDIR_P6} ]] && mkdir -p ${NGANLDIR_P6}
        ${NMV} ${DIAGDIR}/aod_grid/FV3AOD_fv_tracer_aeroanl/* ${NGANLDIR}/
        ERR=$?
        ICNT=$((${ICNT}+${ERR}))

        ${NMV} ${RSTDIR}/* ${NGANLDIR_P6}/
	${NRM} ${NGANLDIR_P6}/*.fv_tracer.res.tile?.nc
        ERR=$?
        ICNT=$((${ICNT}+${ERR}))
    fi

    if [ ${ICNT} -eq 0 ]; then
        echo "Succeeded at ${CDATE} and remove data"
	${NRM} ${HERADIR}/model_data
	${NRM} ${HERADIR}/*.tar
	${NRM} ${HERADIR_ENKF}/*.tar
    else
        echo "Failed at ${CDATE} and exit"
	exit ${ICNT}
    fi
    CDATE=$(${NDATE} ${CYCINC} ${CDATE})
done

exit ${ICNT}
