#!/bin/bash --login
#SBATCH -J LETKF
#SBATCH -A gsd-fv3-dev
##SBATCH --open-mode=truncate
#SBATCH -o log.nemsio2nc
#SBATCH -e log.nemsio2nc
#SBATCH -n 1
##SBATCH --nodes=1
##SBATCH -q debug
#SBATCH -p service
#SBATCH -t 00:30:00

set -x

#module load matlab
#module load python/3.7.5
module load anaconda/latest

SDATE=20230601 # in YYYYMMDDyy
EDATE=20230603 # in YYYYMMDDyy
DATADIR="/scratch1/NCEPDEV/rstprod/Bo.Huang/HpssViirsAod/AWS"
PYEXE="/home/Bo.Huang/JEDI-2020/UFS-Aerosols_RETcyc/UFS-Aerosols-EP4_JEDI-AeroDA-Reanl/misc/awsVIIRS/scripts/viirs_aws_download_globalmode_v1_bo.py"

python ${PYEXE} ${SDATE} ${EDATE} ${DATADIR}

exit 0
