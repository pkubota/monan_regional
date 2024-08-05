#!/bin/bash -x
#-----------------------------------------------------------------------------#
#                                   DIMNT/INPE                                #
#-----------------------------------------------------------------------------#
#BOP
#
# !SCRIPT: runModel
#
# !DESCRIPTION:
#        Script para rodar o MONAN
#        Realiza as seguintes tarefas:
#           o Ungrib os dados do GFS, ERA5
#           o Interpola para grade do modelo
#           o Cria condicao inicial e de fronteria
#           o Integra o modelo MONAN
#           o Pos-processamento (netcdf para grib2, regrid latlon, crop)
#
# !CALLING SEQUENCE:
#     
#
# ./runModel.bash  ${EXP_NAME} ${EXP_RES}   ${LABELI}  ${LABELF}  ${Domain}  ${AreaRegion}  ${TypeGrid}
#
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
#  Extreme event in southern Brazil (flooding)
#
#./runModel.bash    GFS   163842   2024042700  2024050100  regional  Sul  variable_resolution
#
#    Hurricane Catarina
#
#./runModel.bash    ERA5  163842   2004032400  2004032800  regional  Sul       variable_resolution
#
#   meteorological instability line LI-NORDESTE
#
#./runModel.bash    ERA5  163842   2010101600  2010102000  regional  Nordeste  variable_resolution
#
#   meteorological instability line LI-NORTE
#
#./runModel.bash    ERA5  163842   2013043000  2013050400  regional  Norte     variable_resolution
#
#   meteorological easterly wave  NORDESTE
#
#./runModel.bash    ERA5  163842   2019052500  2019052900  regional  Nordeste  variable_resolution
#
# !REVISION HISTORY:
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
   sed -n '/^# !CALLING SEQUENCE:/,/^# !/{p}' ./runModel.bash | head -n -1
}

#
# Verificando argumentos de entrada
#

if [ $# -ne 7 ]; then
   usage
   exit 1
fi
# TODO list:
# - CR: unificar todos exports em load_monan_app_modules.sh
# - DE: Alterar script de modo a poder executar novamente com os diretórios limpos e não precisar baixar os dados novamente
# - DE: Criar função para mensagem


export EXP_NAME=$1  # ERA5 ;  GFS
export EXP_RES=$2 #65536002 # 2621442 #40962  #1024002
export LABELI=$3
export LABELF=$4
export Domain=$5
export AreaRegion=$6  #Belem 
export TypeGrid=$7

export GREEN='\033[1;32m'  # Green
export RED='\033[1;31m'    # Red
export NC='\033[0m'        # No Color

source scripts/VarEnvironmental.bash
source scripts/Function_SetResolution.bash
source scripts/Function_RunModel.bash
source scripts/Function_SetClusterConfig.bash


 VarEnvironmental "export Environmental Variable "
 Function_SetResolution ${EXP_RES} ${TypeGrid} 'set resolution '


echo $RES_KM

. ${DIR_HOME}/run/load_monan_app_modules.sh


echo -e  "${GREEN}==>${NC} Creating submition scripts degrib, atmosphere_model...\n"

Function_RunModel  ${RES_KM} ${EXP_NAME} ${EXP_RES} ${LABELI} ${LABELF}   ${Domain} ${AreaRegion} ${TypeGrid}


cd ${SUBMIT_HOME}/${LABELI}/model/runs/${EXP_NAME}
# TODO list:
# - CR: TODO: trazer o script de submissao do modelo para este script

export GREEN='\033[1;32m'  # Green
export NC='\033[0m'        # No Color

echo -e  "${GREEN}==>${NC} Submitting MONAN and waiting for finish before exit ... \n"
echo -e  "${GREEN}==>${NC} Logs being generated at ${SUBMIT_HOME}${LABELI}/model/runs/${EXP_NAME}/logs ... \n"
echo -e  "sbatch ${SUBMIT_HOME}/${LABELI}/model/runs/${EXP_NAME}/monan_exe.sh"
#sbatch --wait monan_exe.sh
# output files are checked at monan_exe.sh

echo -e "${GREEN}==>${NC} Please, check the output log files at ${SUBMIT_HOME}/${LABELI}/model/runs/${EXP_NAME}/logs to be sure that MONAN ended successfully. \n"
echo -e "${GREEN}==>${NC} Script ${0} completed. \n"
