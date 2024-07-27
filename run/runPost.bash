#!/bin/bash -x
#-----------------------------------------------------------------------------#
#                                   DIMNT/INPE                                #
#-----------------------------------------------------------------------------#
#BOP
#
# !SCRIPT: runPost
#
# !DESCRIPTION:
#        Script para rodar o Post-Processing of MONAN
#        Realiza as seguintes tarefas:
#           o Pos-processamento (netcdf para grib2, regrid latlon, crop)
#
# !CALLING SEQUENCE:
#     
#   ./runPost.bash  ${EXP_NAME} ${EXP_RES}   ${LABELI}  ${LABELF}  ${Domain}  ${AreaRegion}  ${TypeGrid}
#
#
# For GFS datasets
#
#        ./runPost.bash  GFS 535554   2024042700  2024050100  regional  PortoAlegre  variable_resolution
#
#           o EXP_NAME   : Forcing: ERA5, CFSR, GFS, etc.
#           o EXP_RES    : mesh npts : 535554 etc
#           o LABELI     : Initial: date 2015030600
#           o LABELF     : End: date 2015030600
#           o Domain     : Domain: global or regional
#           o AreaRegion : PortoAlegre, Belem, global
#           o TypeGrid   : quasi_uniform or variable_resolution
#
#
# For benchmark:
#
#
# ./runPost.bash GFS      2621442   2024042700  2024050100  regional  PortoAlegre  quasi_uniform
# ./runPost.bash GFS      1024002   2024042700  2024050100  regional  PortoAlegre  quasi_uniform
#
#
# ./runPost.bash GFS       535554   2024042700  2024050100  regional  PortoAlegre  variable_resolution
# ./runPost.bash GFS       163842   2024042700  2024050100  regional  PortoAlegre  variable_resolution
#
# !REVISION HISTORY:
#
# 30 sep 2022 - JPRF
# 12 oct 2022 - GAM Group - MONAN on EGEON DELL cluster
# 23 oct 2022 - GAM Group - MONAN benchmark on EGEON
#
# !REMARKS:
#
#EOP
#-----------------------------------------------------------------------------!
#EOC
function usage(){
   sed -n '/^# !CALLING SEQUENCE:/,/^# !/{p}' ./runPost.bash | head -n -1
}

#
# Verificando argumentos de entrada
#

if [ $# -ne 7 ]; then
   usage
   exit 1
fi

# TODO list:
# - ...

export EXP_NAME=${1}            # ERA5 ;  GFS
export EXP_RES=${2}              #65536002 #2621442            #40962  #1024002
export LABELI=${3}
export LABELF=${4}
export Domain=${5}
export AreaRegion=${6}  #Belem 
export TypeGrid=${7}

export GREEN='\033[1;32m'  # Green
export RED='\033[1;31m' # Red
export NC='\033[0m'        # No Color

source scripts/VarEnvironmental.bash
source scripts/Function_SetResolution.bash
source scripts/Function_SetClusterConfig.bash
source scripts/Function_RunPost.bash
source scripts/Function_Create_ctl.bash

 VarEnvironmental "export Environmental Variable "
 Function_SetResolution ${EXP_RES} ${TypeGrid} 'set resolution '

echo $RES_KM

. ${DIR_HOME}/run/load_monan_app_modules.sh

echo -e  "${GREEN}==>${NC} Creating submition scripts runpost, atmosphere_model...\n"
echo -e  "${GREEN}==>${NC} post_convert.sh...\n"

 Function_RunPost  ${RES_KM} ${EXP_NAME} ${EXP_RES} ${LABELI} ${LABELF}  ${Domain} ${AreaRegion} ${TypeGrid}


exit

