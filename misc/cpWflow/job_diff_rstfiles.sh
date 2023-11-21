#!/bin/bash

SRCDIR=/scratch1/BMC/gsd-fv3-dev/MAPP_2018/bhuang/JEDI-2020/JEDI-FV3/expCodes/UFSAerosols-workflow/20231116-develop/global-workflow/comrot/cycExp_ATMA_warm/enkfgdas.20201221/00/mem001/model_data-stch/atmos/restart
DETDIR=/scratch1/BMC/gsd-fv3-dev/MAPP_2018/bhuang/JEDI-2020/JEDI-FV3/expCodes/UFSAerosols-workflow/20231116-develop/global-workflow/comrot/cycExp_ATMA_warm/enkfgdas.20201221/00/mem001/model_data/atmos/restart

cd ${SRCDIR}
FILES=$(ls *)

for FILE in ${FILES}; do
    diff ${SRCDIR}/${FILE} ${DETDIR}/${FILE}
    ERR=$?
    if [ ${ERR} -ne 0 ]; then
        echo "${FILE} differ ..."
    fi
done
