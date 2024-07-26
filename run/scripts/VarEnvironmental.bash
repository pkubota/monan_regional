#!/bin/bash -x

function VarEnvironmental() {
    local  mensage=$1
    echo   ${mensage}
    export DIR_HOME=`cd ..;pwd`
    export SUBMIT_HOME=`cd ..;pwd`
    export DIRMONAN_PRE_SCR=${SUBMIT_HOME}   # will override scripts at MONAN
    export DIRMONAN_MODEL_SCR=${DIR_HOME}    # will override scripts at MONAN
    export DIRDADOS=/mnt/beegfs/monan/dados/MONAN_v0.1.0 
    export path_mets=/mnt/beegfs/paulo.kubota/monan_project/metis-5.1.0/build/Linux-x86_64/programs

    export NCARG_ROOT=/home/paulo.kubota/.conda/envs/ncl_stable    
    export NCARG_BIN=${NCARG_ROOT}/bin

    export NCAR_Tools=${SUBMIT_HOME}/pre/sources/MPAS-Tools
    export NCAR_MPAS=${NCAR_Tools}/MPAS-Limited-Area


    export GREEN='\033[1;32m'  # Green
    export RED='\033[1;31m'    # Red
    export NC='\033[0m'        # No Color
}
