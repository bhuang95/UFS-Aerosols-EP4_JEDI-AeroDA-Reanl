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

#export OMP_NUM_THREADS=1
#set -x 

#module use -a /contrib/anaconda/modulefiles
#module load anaconda/latest

RUNDIR=/scratch2/BMC/gsd-fv3-dev/bhuang/expRuns/UFS-Aerosols_RETcyc/AeroReanl/PrepPaper/AERONET/ScatterPlot
OUTDIR=${RUNDIR}/Samples
cd ${RUNDIR}

[[ ! -d ${OUTDIR} ]] && mkdir -p ${OUTDIR}
EXPDIR=/scratch2/BMC/gsd-fv3-dev/bhuang/expRuns/UFS-Aerosols_RETcyc/AeroReanl

YEARS="2018 2019 2020 2021 2022"
DJF="12 01 02"
MAM="03 04 05"
JJA="06 07 08"
SON="09 10 11"

SEASONS="DJF MAM JJA SON"
#SEASONS="DJF"

DAYS28="02"
DAYS30="04 06 09 11"
DAYS31="01 03 05 07 08 10 12"


for ISEASON in ${SEASONS}; do
    echo "##################${ISEASON} collection starts now."
    if [ ${ISEASON} = "DJF" ]; then
        MONS=${DJF}
    elif [ ${ISEASON} = "MAM" ]; then
        MONS=${MAM}
    elif [ ${ISEASON} = "JJA" ]; then
        MONS=${JJA}
    elif [ ${ISEASON} = "SON" ]; then
        MONS=${SON}
    else
	echo "Season not correctly set and exit."
	exit 100
    fi

    FREERUN_CNTLBKG_OUT=${OUTDIR}/${ISEASON}_freerun_cntlbkg_aeronet_aod_500nm_sample.out
    AERODA_CNTLBKG_OUT=${OUTDIR}/${ISEASON}_aeroda_cntlbkg_aeronet_aod_500nm_sample.out
    AERODA_CNTLANL_OUT=${OUTDIR}/${ISEASON}_aeroda_cntlanl_aeronet_aod_500nm_sample.out

    [[ -f ${FREERUN_CNTLBKG_OUT} ]] && rm -rf ${FREERUN_CNTLBKG_OUT}
    [[ -f ${AERODA_CNTLBKG_OUT} ]] && rm -rf ${AERODA_CNTLBKG_OUT}
    [[ -f ${AERODA_CNTLANL_OUT} ]] && rm -rf ${AERODA_CNTLANL_OUT}

    ICNT=0
    for IMON in ${MONS}; do
        if ( echo ${DAYS28} | grep ${IMON} ); then
            ENDDAY="28"
        elif ( echo ${DAYS30} | grep ${IMON} ); then
            ENDDAY="30"
        elif ( echo ${DAYS31} | grep ${IMON} ); then
            ENDDAY="31"
        else
	    echo "Months not correctly set and exit."
	    exit 100
        fi

        for IYEAR in ${YEARS}; do
            YM=${IYEAR}${IMON}
	    echo ${YM}
	    if [ ${YM} -lt "202007" ]; then
	        AERODAEXP="AeroReanl_EP4_AeroDA_YesSPEEnKF_YesSfcanl_v14_0dz0dp_41M_C96_201801"
		FREERUNEXP="AeroReanl_EP4_FreeRun_NoSPE_YesSfcanl_v14_0dz0dp_1M_C96_201801"
	    else
	        AERODAEXP="AeroReanl_EP4_AeroDA_YesSPEEnKF_YesSfcanl_v15_0dz0dp_41M_C96_202007"
		FREERUNEXP="AeroReanl_EP4_FreeRun_NoSPE_YesSfcanl_v15_0dz0dp_1M_C96_202007"
	    fi
	    SAMPST=${YM}0100
	    SAMPED=${YM}${ENDDAY}18
	    SAMPDIR=${EXPDIR}/${AERODAEXP}/diagplots/AERONET/AERONET_SOLAR_AOD15/PLOTS-${SAMPST}-${SAMPED}
	    FREERUN_CNTLBKG=${SAMPDIR}/${FREERUNEXP}_cntlBkg_AERONET_SOLAR_AOD15_${SAMPST}_${SAMPED}.out
	    AERODA_CNTLBKG=${SAMPDIR}/${AERODAEXP}_cntlBkg_AERONET_SOLAR_AOD15_${SAMPST}_${SAMPED}.out
	    AERODA_CNTLANL=${SAMPDIR}/${AERODAEXP}_cntlAnl_AERONET_SOLAR_AOD15_${SAMPST}_${SAMPED}.out

	    #echo "${FREERUN_CNTLBKG}"
	    echo $(basename "${FREERUN_CNTLBKG}")
	    cat ${FREERUN_CNTLBKG} >> ${FREERUN_CNTLBKG_OUT}
	    ICNT=$(($ICNT + $?))

	    #echo "${AERODA_CNTLBKG}"
	    echo $(basename "${AERODA_CNTLBKG}")
	    cat ${AERODA_CNTLBKG} >> ${AERODA_CNTLBKG_OUT}
	    ICNT=$(($ICNT + $?))

	    #echo "${AERODA_CNTLANL}"
	    echo $(basename "${AERODA_CNTLANL}")
	    cat ${AERODA_CNTLANL} >> ${AERODA_CNTLANL_OUT}
	    ICNT=$(($ICNT + $?))

	    w1=$(cat ${FREERUN_CNTLBKG_OUT} | wc -l )
	    w2=$(cat ${AERODA_CNTLBKG_OUT} | wc -l )
	    w3=$(cat ${AERODA_CNTLANL_OUT} | wc -l )
	    echo "${w1}==${w2}==${w3}"
	    if [ ${w1} -ne ${w2} ] || [ ${w1} -ne ${w3} ]; then
	        echo "Total counts in ${YM} are not the same and exit."
		exit 200
	    fi
        done # IYEAR
    done # IMON
    if [ ${ICNT} = 0 ]; then
        echo "${ISEASON} succeed!"
    else
        echo "${ISEASON} failed and exit."
	echo ${ICNT}
    fi
    echo "##################${ISEASON} collection ends now."
done

exit 0

