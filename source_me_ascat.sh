#!/bin/bash

module purge
unset R_LIBS
unset R_LIBS_USER

export DERMATLAS_R_LIB="/software/team113/dermatlas/R/R-4.2.2/lib/R/library"
export SINGULARITYENV_DERMATLAS_R_LIB="${DERMATLAS_R_LIB}"
module load dermatlas-ascat/3.1.2__v0.1.1 

echo $R_LIBS
echo $DERMATLAS_R_LIB
