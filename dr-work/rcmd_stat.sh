#!/bin/bash

module load rocoto
rocotostat -w cycExp_ATMA_warm.xml -d cycExp_ATMA_warm.db | less
