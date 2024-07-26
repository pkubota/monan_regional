#!/bin/bash -x
#---------------------------------------------------------------------------------------------#
#                                           DIMNT/INPE                                        #
#---------------------------------------------------------------------------------------------#
#BOP
#
# !SCRIPT: run_monan
#
# !DESCRIPTION:
#        Script para rodar o MONAN
#        Realiza as seguintes tarefas:
#           o Ungrib os dados do GFS, ERA5
#           o Interpola para grade do modelo
#           o Cria condicao inicial e de fronteria
#           o Integra o modelo MONAN
#           o Pre-processamento (netcdf para grib2, regrid latlon, crop)
#
# !CALLING SEQUENCE:
#     
#./runPre.bash EXP_NAME EXP_RES   LABELI      LABELF      Domain    AreaRegion   TypeGrid
#
#           o EXP_NAME   : Forcing: ERA5, CFSR, GFS, etc.
#           o EXP_RES    : Resolution: 1024002 (24km), 2621442
#           o LABELI     : Initial: date 2015030600
#           o LABELF     : End:     date 2015030600 
#           o Domain     : global  or regional
#           o AreaRegion : PortoAlegre
#           o TypeGrid   : quasi_uniform or variable_resolution
#
#
# For benchmark:
#        ./runPre.bash CFSR 1024002 2010102300 24
#./runPre.bash GFS      2621442   2024042700  2024050100  regional  PortoAlegre  quasi_uniform
#./runPre.bash GFS       535554   2024042700  2024050100  regional  PortoAlegre  variable_resolution
#
#
# !REVISION HISTORY:
# 30 sep 2022 - JPRF
# 12 oct 2022 - GAM Group - MONAN on EGEON DELL cluster
# 23 oct 2022 - GAM Group - MONAN benchmark on EGEON
#
# !REMARKS:
#
# TODO list:
# - CR: unificar todos exports em load_monan_app_modules.sh
# - DE: Alterar script de modo a poder executar novamente com os diretórios limpos e
#       nao precisar baixar os dados novamente
# - DE: Criar função para mensagem
#EOP
#-----------------------------------------------------------------------------!
#EOC

function usage(){
   sed -n '/^# !CALLING SEQUENCE:/,/^# !/{p}' ./runPre.bash | head -n -1
}
#
# Verificando argumentos de entrada
#
if [ $# -ne 7 ]; then
   usage
   exit 1
fi
#
#  Get Parameter Arguments
#
export EXP_NAME=${1}        # ERA5 ;  GFS
export EXP_RES=${2}         #65536002 #40962  #1024002
export LABELI=${3}
export LABELF=${4}
export Domain=${5}          # regional
export AreaRegion=${6}      #Belem
export TypeGrid=${7}        #TypeGrid=variable_resolution
#
# Activity Functions
#
source scripts/VarEnvironmental.bash
source scripts/Function_SetClusterConfig.bash
source scripts/Function_GridRotate.bash
source scripts/Function_SetResolution.bash
source scripts/Function_RecDomain.bash
source scripts/Function_PlotDomain.bash
source scripts/Function_Static.sh
source scripts/Function_Degrib_IC_ERA5.bash
source scripts/Function_InitAtmos_IC_ERA5.bash
source scripts/Function_Degrib_IC_GFS.bash
source scripts/Function_InitAtmos_IC_GFS.bash
source scripts/Function_Degrib_LBC_GFS.bash
source scripts/Function_InitAtmos_LBC_GFS.bash
source scripts/Function_Degrib_SST_GFS.bash
source scripts/Function_InitAtmos_SST_GFS.bash
source scripts/Function_InitAtmos_SST_CLM.bash
#
# Activity Modules
#
source ${DIR_HOME}/run/load_monan_app_modules.sh
#
# Execute Functions
#
 VarEnvironmental       "export Environmental Variable "
 Function_SetResolution ${EXP_RES} ${TypeGrid} 'set resolution '

echo -e  "${GREEN}==>${NC} Creating Function_GridRotate.sh for...\n"

  Function_GridRotate ${RES_KM} ${EXP_RES} ${frac} ${Domain} ${AreaRegion} ${TypeGrid}

echo -e  "${GREEN}==>${NC} Creating Function_RecDomain.sh for...\n"

  Function_RecDomain ${RES_KM} ${EXP_RES} ${frac} ${Domain} ${AreaRegion} ${TypeGrid}

echo -e  "${GREEN}==>${NC} Plot Domain.sh for...\n"

  Function_PlotDomain ${RES_KM} ${EXP_RES} ${frac} ${Domain} ${AreaRegion} ${TypeGrid}

echo -e  "${GREEN}==>${NC} Creating make_static.sh for submiting init_atmosphere...\n"

  Function_static ${RES_KM} ${EXP_NAME} ${EXP_RES}  ${LABELI} ${Domain} ${AreaRegion} ${TypeGrid}

if [ ${EXP_NAME} = "ERA5" ]; then
echo -e  "${GREEN}==>${NC} Creating submition scripts degrib, atmosphere_model...\n"

  Function_Degrib_IC_ERA5 ${RES_KM} ${EXP_NAME} ${EXP_RES}  ${LABELI} ${LABELF} ${Domain} ${AreaRegion} ${TypeGrid}

echo -e  "${GREEN}==>${NC} Submiting InitAtmos_ic_exe.sh...\n"

  Function_InitAtmos_IC_ERA5 ${RES_KM} ${EXP_NAME} ${EXP_RES}  ${LABELI} ${LABELF} ${Domain} ${AreaRegion} ${TypeGrid}


echo -e  "${GREEN}==>${NC} Submiting CLM InitAtmosSST_exe.sh...\n"

 Function_InitAtmos_SST_CLM    ${RES_KM} ${EXP_NAME} ${EXP_RES}  ${LABELI} ${LABELF} ${Domain} ${AreaRegion} ${TypeGrid}

else

echo -e  "${GREEN}==>${NC} Creating submition scripts degrib, atmosphere_model...\n"

  Function_Degrib_IC_GFS ${RES_KM} ${EXP_NAME} ${EXP_RES}  ${LABELI} ${LABELF} ${Domain} ${AreaRegion} ${TypeGrid}

echo -e  "${GREEN}==>${NC} Submiting InitAtmos_ic_exe.sh...\n"

  Function_InitAtmos_IC_GFS ${RES_KM} ${EXP_NAME} ${EXP_RES}  ${LABELI} ${LABELF} ${Domain} ${AreaRegion} ${TypeGrid}

echo -e  "${GREEN}==>${NC} Submiting degriblbc_exe.sh...\n"

  Function_Degrib_LBC_GFS ${RES_KM} ${EXP_NAME} ${EXP_RES}  ${LABELI} ${LABELF} ${Domain} ${AreaRegion} ${TypeGrid}

echo -e  "${GREEN}==>${NC} Submiting InitAtmos_lbc_exe.sh...\n"

  Function_InitAtmos_LBC_GFS  ${RES_KM} ${EXP_NAME} ${EXP_RES}  ${LABELI} ${LABELF} ${Domain} ${AreaRegion} ${TypeGrid}

fi

#PK echo -e  "${GREEN}==>${NC} Submiting degribsst_exe.sh...\n"

#PK Function_Degrib_SST_GFS   ${RES_KM} ${EXP_NAME} ${EXP_RES}  ${LABELI} ${LABELF} ${Domain} ${AreaRegion} ${TypeGrid}

#PK echo -e  "${GREEN}==>${NC} Submiting InitAtmosSST_exe.sh...\n"

#PK Function_InitAtmos_SST_GFS    ${RES_KM} ${EXP_NAME} ${EXP_RES}  ${LABELI} ${LABELF} ${Domain} ${AreaRegion} ${TypeGrid}

#echo -e  "${GREEN}==>${NC} Submiting CLM InitAtmosSST_exe.sh...\n"

#PK Function_InitAtmos_SST_CLM    ${RES_KM} ${EXP_NAME} ${EXP_RES}  ${LABELI} ${LABELF} ${Domain} ${AreaRegion} ${TypeGrid}

