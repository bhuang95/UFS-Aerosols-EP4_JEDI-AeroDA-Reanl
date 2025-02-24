#!/bin/bash --login
#SBATCH -J fixgbbepx
#SBATCH -A gsd-fv3-dev
#SBATCH -n 1
#SBATCH --mem=5g
#SBATCH -t 24:00:00
#SBATCH -p service
#SBATCH -D ./
#SBATCH -o fixgbbepx.out
#SBATCH -e fixgbbepx.out

module load  intel/2022.1.2 netcdf nco
set -x

#SCRIPTDIR="/home/Bo.Huang/JEDI-2020/UFS-Aerosols_RETcyc/UFS-Aerosols-EP4_JEDI-AeroDA-Reanl/misc/hpssVIIRS/fromHPSS"
#cd ${SCRIPTDIR}
TOPDIR="/scratch1/BMC/gsd-fv3-dev/MAPP_2018/bhuang/JEDI-2020/JEDI-FV3/expCodes/PACEData/GBBEPx"
SDATE="2024030100" #$(cat SDAY.info)
EDATE="2024043000" #$(cat EDAY.info)
EXP="Prep_GBBEPx_2024030100_2024043000"
EXPDIR=${TOPDIR}/${EXP}
TMPDIR=${EXPDIR}/tmp
OUTDIR=${EXPDIR}/FixGBBEPx
CYCINC=24

mkdir -p ${TMPDIR}
mkdir -p ${OUTDIR}
NDATE="/scratch2/NCEPDEV/nwprod/NCEPLIBS/utils/prod_util.v1.1.0/exec/ndate"
FIXEXE="/home/Bo.Huang/JEDI-2020/UFS-Aerosols_RETcyc/UFS-Aerosols-EP4_JEDI-AeroDA-Reanl/misc/PrepPACE/GBBEPx/fix_GBBEPx_Li.sh"

SDATE=$(${NDATE} -${CYCINC} ${SDATE})
IDATE=${SDATE}
cd ${TMPDIR}
while [ ${IDATE} -le ${EDATE} ]; do
    ECNT=0
    /bin/rm -rf *.tmp* *.nc
    IY=${IDATE:0:4}
    IM=${IDATE:4:2}
    ID=${IDATE:6:2}
    IYMD=${IDATE:0:8}
    SRCFILE=${EXPDIR}/${IDATE}/*.nc
    OUTFILE=${OUTDIR}/GBBEPx_all01GRID.emissions_v004_${IYMD}.nc
    NNC=$(ls ${SRCFILE} | wc -l)
    if [ ${NNC} -eq 1 ]; then
       for FILE in $(ls ${SRCFILE}); do
           /bin/cp ${FILE} input.nc
	   ERR=$?
	   ECNT=$((${ECNT}+${ERR}))
       done
    else
       echo "Multiple nc file or none exist and exit."
       exit 100
    fi

${FIXEXE} input.nc ${IYMD}
    ERR=$?
    ECNT=$((${ECNT}+${ERR}))
    if [ ${ECNT} -eq 0 ]; then
        /bin/mv input.nc.tmp4 ${OUTFILE}
        ERR=$?
        ECNT=$((${ECNT}+${ERR}))
    fi

    if [ ${ECNT} -eq 0 ]; then
        echo "Fix GBBEPx successflully at ${IYMD}"
    else
        echo "Fixing GBBEPx failed at ${IYMD} and exit"
	exit ${ECNT}
    fi
    IDATE=$(${NDATE} ${CYCINC} ${IDATE})
done

exit ${ERR}
