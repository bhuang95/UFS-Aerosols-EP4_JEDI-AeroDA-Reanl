#!/bin/bash
#SBATCH -n 1
#SBATCH -t 23:59:00
#SBATCH -p service
#SBATCH -A chem-var
#SBATCH -J aodinc_202007
#SBATCH -D ./
#SBATCH -o /scratch2/BMC/gsd-fv3-dev/MAPP_2018/bhuang/JEDI-2020/JEDI-FV3/miscLog/VIIRS_AOD_INCREMENT_IODAV3_202007.out
#SBATCH -e /scratch2/BMC/gsd-fv3-dev/MAPP_2018/bhuang/JEDI-2020/JEDI-FV3/miscLog/VIIRS_AOD_INCREMENT_IODAV3_202007.out


# This jobs plots the AOD, HOFX and their difference in a 3X1 figure.
set -x 

module use -a /contrib/anaconda/modulefiles
module load anaconda/latest

codedir=$(pwd)
#topexpdir=/scratch2/BMC/gsd-fv3-dev/bhuang/expRuns/UFS-Aerosols_RETcyc
topexpdir=/scratch2/BMC/gsd-fv3-dev/bhuang/expRuns/UFS-Aerosols_RETcyc/AeroReanl/

ndate=/scratch2/NCEPDEV/nwprod/NCEPLIBS/utils/prod_util.v1.1.0/exec/ndate

cycst=2021120100   #2021090100  #2021070100  #2021040100  #2021030100  #2021010100  #2020110118  #2020090100  #2020080100  #2020070100
cyced=2022022818   #2021113018  #2021083118  #2021063018  #2021033118  #2021022818  #2020123118  #2020103118  #2020083118  #2020073100
#cycst=2020061400
#cyced=2020062900
# (if cycinc=24, set cycst and cyced as YYYYMMDD00)
cycinc=24 
# (6 or 24 hours)


#freerunexp="RET_EP4_FreeRun_NoSPE_YesSfcanl_v15_0dz0dp_1M_C96_202006"
freerunexp="AeroReanl_EP4_FreeRun_NoSPE_YesSfcanl_v15_0dz0dp_1M_C96_202007"
#aerodaexp="RET_EP4_AeroDA_NoSPE_YesSfcanl_v15_0dz0dp_41M_C96_202006"
#aerodaexp="RET_EP4_AeroDA_YesSPEEnKF_YesSfcanl_v15_0dz0dp_41M_C96_202006"
aerodaexp="AeroReanl_EP4_AeroDA_YesSPEEnKF_YesSfcanl_v15_0dz0dp_41M_C96_202007"
#"RET_EP4_AeroDA_NoSPE_YesSfcanl_v14_0dz0dp_41M_C96_201712"


exps="${aerodaexp}"

for exp in ${exps}; do
    topplotdir=${topexpdir}/${exp}/diagplots/VIIRS_AOD_HOFX_INCREMENT_IODAV3
    if [ ${exp} = ${aerodaexp} ]; then
        aeroda=True
        emean=False
        prefix=AeroDA_YesSPE
    elif [ ${exp} = ${freerunexp} ]; then
        aeroda=False
        emean=False
        prefix=FreeRun
    else
	echo "Please deefine aeroda, emean, prefix accordingly for your exps"
    fi

    datadir=${topexpdir}/${exp}/dr-data-backup

    plotdir=${topplotdir}/${prefix}
    [[ ! -d ${plotdir} ]] && mkdir -p ${plotdir}

    cp plt_VIIRS_AOD_INCREMENT_IODAV3.py ${plotdir}/plt_VIIRS_AOD_INCREMENT_IODAV3.py

    cd ${plotdir}

    cyc=${cycst}
    while [ ${cyc} -le ${cyced} ]; do
        echo ${cyc}
        python plt_VIIRS_AOD_INCREMENT_IODAV3.py -c ${cyc} -i ${cycinc} -a ${aeroda} -m ${emean} -p ${prefix} -t ${datadir}
        ERR=$?
        [[ ${ERR} -ne 0 ]] && exit 100
        cyc=$(${ndate} ${cycinc} ${cyc})
    done
done
exit
