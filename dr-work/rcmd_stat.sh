#!/bin/bash

module load rocoto
#rocotostat -w cycExp_ATMA_warm.xml -d cycExp_ATMA_warm.db | less
rocotostat -w RET_AeroDA_NoEmisStoch_C96_202006.xml -d RET_AeroDA_NoEmisStoch_C96_202006.db | less
