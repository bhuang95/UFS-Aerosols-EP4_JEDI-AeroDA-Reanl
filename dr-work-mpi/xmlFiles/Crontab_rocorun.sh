#!/bin/bash
#set -x

#rocotostat -w /home/Bo.Huang/JEDI-2020/UFS-Aerosols_NRTcyc/UFS-Aerosols_JEDI-AeroDA-1C192-20C192_NRT/dr-work-RetExp/RET_ENKF_AEROSEMIS-ON_STOCHINIT-OFF-201710.xml -d /scratch2/BMC/gsd-fv3-dev/MAPP_2018/bhuang/JEDI-2020/JEDI-FV3/expRuns/UFS-Aerosols_RETcyc/ENKF_AEROSEMIS-ON_STOCHINIT-OFF-201710/dr-work/RET_ENKF_AEROSEMIS-ON_STOCHINIT-OFF-201710.db

RORUNCMD="/apps/rocoto/1.3.3/bin/rocotorun"
XMLDIR="/home/Bo.Huang/JEDI-2020/UFS-Aerosols_RETcyc/UFS-Aerosols-EP4_JEDI-AeroDA-Reanl/dr-work-mpi/xmlFiles/"
DBDIR="/scratch2/BMC/gsd-fv3-dev/bhuang/expRuns/UFS-Aerosols_RETcyc/"
COMDBDIR="/scratch2/BMC/gsd-fv3-dev/bhuang/expRuns/UFS-Aerosols_RETcyc/comDB"

EXPS="
    RET_EP4_AeroDA_NoSPE_YesSfcanl_v15_0dz0dp_41M_C96_202006
    RET_EP4_AeroDA_YesSPEEnKF_YesSfcanl_v15_0dz0dp_41M_C96_202006
"
#    RET_EP4_FreeRun_NoSPE_YesSfcanl_v15_0dz0dp_1M_C96_202006
#    RET_EP4_SpinUp_NoSfcanl_v15_0delz0delp_41M_C96_202005
#    RET_EP4_SpinUp_YesSfcanl_v15_0delz0delp_41M_C96_202005
#    RET_EP4_SpinUp_NoSfcanl_v15_0delz_41M_C96_202005
#    RET_EP4_SpinUp_NoSfcanl_v15_0delz0delp_41M_C96_202005
#    RET_EP4_SpinUp_NoSfcanl_v15_0delz_41M_C96_202005
	#RET_EP4_SpinUp_YesSfcanl_v15_0delz_41M_C96_202005
#        RET_EP4_SpinUp_41M_C96_201711

for EXP in ${EXPS}; do
    echo "${RORUNCMD} -w ${XMLDIR}/${EXP}.xml -d ${DBDIR}/${EXP}/dr-work/${EXP}.db"
    ${RORUNCMD} -w ${XMLDIR}/${EXP}.xml -d ${DBDIR}/${EXP}/dr-work/${EXP}.db
done

EXPS="
    RET_EP4_AeroDA_NoSPE_YesSfcanl_v15_0dz0dp_41M_C96_202006_Diag
    RET_EP4_AeroDA_YesSPEEnKF_YesSfcanl_v15_0dz0dp_41M_C96_202006_Diag
    RET_EP4_FreeRun_NoSPE_YesSfcanl_v15_0dz0dp_1M_C96_202006_LongFcst
    RET_EP4_FreeRun_NoSPE_YesSfcanl_v15_0dz0dp_1M_C96_202006_LongFcst_Diag

"
#    RET_EP4_FreeRun_NoSPE_YesSfcanl_v15_0dz0dp_1M_C96_202006_Diag

for EXP in ${EXPS}; do
    echo "${RORUNCMD} -w ${XMLDIR}/${EXP}.xml -d ${COMDBDIR}/${EXP}.db"
    ${RORUNCMD} -w ${XMLDIR}/${EXP}.xml -d ${COMDBDIR}/${EXP}.db
done

#TASKS="
#       RET_ENKF_AEROSEMIS-ON_STOCHINIT-OFF-201710
#       "
#
#       #NRT-prepEmis 
#       #NRT-prepGDAS 
#       #NRT-freeRun 
#       #NRT-aeroDA
#       #NRT-postDiag-aodObs-freeRun
#       #NRT-postDiag-aodObs-aeroDA
#for TASK in ${TASKS}; do
#    echo "Run ${TASK}"
#    ${RORUNCMD} -w ${XMLDIR_DA}/${TASK}.xml -d ${DBDIR_DA}/${TASK}.db
#done
