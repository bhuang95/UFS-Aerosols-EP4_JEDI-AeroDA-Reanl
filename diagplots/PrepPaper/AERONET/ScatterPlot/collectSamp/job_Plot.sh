#!/bin/bash
#SBATCH -n 1
#SBATCH -t 03:30:00
#SBATCH -p service
##SBATCH -q debug
#SBATCH -A chem-var
#SBATCH -J AERONET-PLOT
#SBATCH -D ./
#SBATCH -o /scratch2/BMC/gsd-fv3-dev/MAPP_2018/bhuang/JEDI-2020/JEDI-FV3/miscLog/plotAeronet_201801.out
#SBATCH -e /scratch2/BMC/gsd-fv3-dev/MAPP_2018/bhuang/JEDI-2020/JEDI-FV3/miscLog/plotAeronet_201801.out

export OMP_NUM_THREADS=1
set -x 

module use -a /contrib/anaconda/modulefiles
module load anaconda/latest

EXPDIR=/scratch2/BMC/gsd-fv3-dev/bhuang/expRuns/UFS-Aerosols_RETcyc/AeroReanl
SAMPDIR=/scratch2/BMC/gsd-fv3-dev/bhuang/expRuns/UFS-Aerosols_RETcyc/AeroReanl/PrepPaper/AERONET/ScatterPlot/Samples
PLOTDIR=/scratch2/BMC/gsd-fv3-dev/bhuang/expRuns/UFS-Aerosols_RETcyc/AeroReanl/PrepPaper/AERONET/ScatterPlot/Plots

[[ ! -d ${PLOTDIR} ]] && mkdir -p ${PLOTDIR}

cp *.py ${PLOTDIR}
cd ${PLOTDIR}

FIELDS="freerun_cntlbkg aeroda_cntlbkg aeroda_cntlanl"
SEASONS="DJF MAM JJA SON"
#SEASONS="DJF"
COMP_ERROR="YES"

PY_COLECT_ERROR=COLLECT_AERONET_AOD_COUNT_OBS_HFX_BIAS_RMSE_MAE_BRRMSE_500nm.py
PY_PLOT_PDF=plt_AERONET_AOD_OBS_HFX_MPL_PDF_500nm.py
PY_PLOT_ERROR=plt_AERONET_AOD_COUNT_BIAS_RMSE_MAE_BRRMSE_500nm_relativeError.py

if [ ${COMP_ERROR} = "YES" ]; then
for ISEASON in ${SEASONS}; do
    for IFIELD in ${FIELDS}; do
        echo "${ISEASON}-${IFIELD}-Collect bias and RMSE."	
        INFILE=${SAMPDIR}/${ISEASON}_${IFIELD}_aeronet_aod_500nm_sample.out
        OUTFILE=${SAMPDIR}/${ISEASON}_${IFIELD}_aeronet_aod_500nm_count_obs_hfx_bias_rmse_mae_brrmse_sample.out
        python ${PY_COLECT_ERROR} -i ${INFILE} -o ${OUTFILE}
        ERR=$?
        [[ ${ERR} -ne 0 ]] && exit 1
    done
done
fi

for ISEASON in ${SEASONS}; do
    echo "${ISEASON}-Plot PDF."
    CYCLE="${ISEASON}"
    AODTYPE="AERONET"
    PMONTH="FALSE"
    FREERUN="${SAMPDIR}/${ISEASON}_freerun_cntlbkg_aeronet_aod_500nm_sample.out"
    DABKG="${SAMPDIR}/${ISEASON}_aeroda_cntlbkg_aeronet_aod_500nm_sample.out"
    DAANL="${SAMPDIR}/${ISEASON}_aeroda_cntlanl_aeronet_aod_500nm_sample.out"
    python ${PY_PLOT_PDF} -c ${CYCLE} -p ${AODTYPE} -m ${PMONTH} -x ${FREERUN} -y ${DABKG} -z ${DAANL}
    ERR=$?
    [[ ${ERR} -ne 0 ]] && exit 1

    FREERUN="${SAMPDIR}/${ISEASON}_freerun_cntlbkg_aeronet_aod_500nm_count_obs_hfx_bias_rmse_mae_brrmse_sample.out"
    DABKG="${SAMPDIR}/${ISEASON}_aeroda_cntlbkg_aeronet_aod_500nm_count_obs_hfx_bias_rmse_mae_brrmse_sample.out"
    DAANL="${SAMPDIR}/${ISEASON}_aeroda_cntlanl_aeronet_aod_500nm_count_obs_hfx_bias_rmse_mae_brrmse_sample.out"

    python ${PY_PLOT_ERROR} -c ${CYCLE} -p ${AODTYPE} -x ${FREERUN} -y ${DABKG} -z ${DAANL}
    ERR=$?
    [[ ${ERR} -ne 0 ]] && exit 1
done
exit ${ERR}

#########
