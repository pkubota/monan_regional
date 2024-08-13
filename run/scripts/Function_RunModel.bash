#!/bin/bash -x

# Define a function with local variables

Function_RunModel() {
#-----------------------------------------------------------------------------#
#                                   DIMNT/INPE                                #
#-----------------------------------------------------------------------------#
#BOP
#
# !SCRIPT: Function_RunModel
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
#        ./Function_RunModel.egeon EXP_NAME RES LABELI
#
# For benchmark:
#        ./Function_RunModel.egeon CFSR ${EXP_RES} 2010102300
#
# For ERA5 datasets
#
#        ./Function_RunModel.egeon ERA5 ${EXP_RES} 2021010100
#        ./Function_RunModel  ${RES_KM} ${EXP_NAME} ${EXP_RES} ${LABELI} ${LABELF}  ${Domain} ${AreaRegion} ${TypeGrid}
#           o RES_KM     : 060_015km
#           o EXP_NAME   : GFS, ERA5
#           o EXP_RES    : mesh npts : 535554 etc
#           o LABELI     : Initial: date 2015030600
#           o LABELF     : End: date 2015030600
#           o Domain     : Domain: global or regional
#           o AreaRegion : PortoAlegre, Belem, global
#           o TypeGrid   : quasi_uniform or variable_resolution
#
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
   sed -n '/^# !CALLING SEQUENCE:/,/^# !/{p}' ./scripts/Function_RunModel.bash | head -n -1
}

#
# Verificando argumentos de entrada
#

if [ $# -ne 8 ]; then
   usage
   exit 1
fi

#
# pegando argumentos
#
RES_KM=${1}
EXP_NAME=${2}
EXP_RES=${3}
LABELI=${4}; start_date=${LABELI:0:4}-${LABELI:4:2}-${LABELI:6:2}_${LABELI:8:2}:00:00
start_check=${LABELI:0:4}-${LABELI:4:2}-${LABELI:6:2}_${LABELI:8:2}.00.00
start_check2=${LABELI:0:4}-${LABELI:4:2}-${LABELI:6:2}_${LABELI:8:2}
LABELF=${5};end_date=${LABELF:0:4}-${LABELF:4:2}-${LABELF:6:2}_${LABELF:8:2}:00:00

Domain=${6}
AreaRegion=${7}
TypeGrid=${8}

#
# Caminhos
#
HSTMAQ=$(hostname)
RUNDIR=${SUBMIT_HOME}/${LABELI}/model/runs
TBLDIR=${SUBMIT_HOME}/pre/tables
NMLDIR=${SUBMIT_HOME}/model/namelist/${version_model}
EXECPATH=${SUBMIT_HOME}/model/exec/${version_model}/exec
DIR_MESH=${SUBMIT_HOME}/pre/databcs/meshes/${TypeGrid}/${Domain}/${RES_KM}/
EXPDIR=${RUNDIR}/${EXP_NAME}
LOGDIR=${EXPDIR}/logs

#
# Initial Conditions: 
#
# GFS operacional                    GFS
# GFS analysis                       FNL
# ERA5 reanalysis                    ERA5
#
USERDATA=${EXP_NAME}

BNDDIR=${SUBMIT_HOME}/${LABELI}/pre/runs/${USERDATA}/${AreaRegion}.${EXP_RES}.init.nc

echo $BNDDIR

if [ ! -f ${BNDDIR} ]; then
     echo "Condicao de contorno inexistente !"
     echo "Verifique a data da rodada."
     echo "$0 ${LABELI}"
     exit 1                     # close for running only the model
fi

#  os tamanhos dos intervalos de tempo geralmente recebem o valor de 6x do espaçamento da grade em km.

 Function_SetClusterConfig ${EXP_RES} ${TypeGrid} 'set Function_SetClusterConfig '

#
# Criando diretorios da rodada
#
# logs
# scripts
# pre-processing
# production 
# post-processing: 
# tables
# parameters
#
if [ ! -e ${EXPDIR} ]; then
   mkdir -p ${EXPDIR}
   mkdir -p ${EXPDIR}/logs
   mkdir -p ${EXPDIR}/monanprd
   cp -u ${SUBMIT_HOME}/${LABELI}/pre/runs/${EXP_NAME}/${AreaRegion}.${EXP_RES}.init.nc ${SUBMIT_HOME}/${LABELI}/model/runs/${EXP_NAME}/
else
   mkdir -p ${EXPDIR}/logs
   mkdir -p ${EXPDIR}/monanprd
   cp -u ${SUBMIT_HOME}/${LABELI}/pre/runs/${EXP_NAME}/${AreaRegion}.${EXP_RES}.init.nc ${SUBMIT_HOME}/${LABELI}/model/runs/${EXP_NAME}/
fi
#

###############################################################################
#
#                             Rodando o Modelo
#
###############################################################################

#
# Configuracoes para o modelo (pre-operacao/demo)
#

cd ${EXPDIR}

JobName=MONAN.GNU        # Nome do Job

cp -u ${EXECPATH}/atmosphere_model ${EXPDIR}

cp -u ${TBLDIR}/* .

sed -e "s,#LEN_DISP#,${len_disp},g; s,#LABELI#,${start_date},g;s,#LABELF#,${end_date},g;s,#RESNPTS#,${EXP_RES},g;s,#STEPMODEL#,${dt_step},g;s,#x1#,${AreaRegion},g" \
         ${NMLDIR}/namelist.atmosphere.TEMPLATE.${Domain} > ${EXPDIR}/namelist.atmosphere

sed -e "s,#RESNPTS#,${EXP_RES},g;s,#x1#,${AreaRegion},g" \
	 ${NMLDIR}/streams.atmosphere.TEMPLATE.${Domain} > ${EXPDIR}/streams.atmosphere

cp -u ${NMLDIR}/stream_list.atmosphere.* .

ln -sf ${DIR_MESH}/${AreaRegion}.${EXP_RES}.graph.info.part.${cores_model} .

cd ${EXPDIR}

cat > ${EXPDIR}/monan_exe.sh <<EOF0
#!/bin/bash -x
#SBATCH --nodes=${nodes_model}
#SBATCH --ntasks=${cores_model}
#SBATCH --tasks-per-node=128
#SBATCH --partition=batch
#SBATCH --job-name=${JobName}
#SBATCH --time=12:00:00         
#SBATCH --output=${LOGDIR}/my_job_monan.o%j   # File name for standard output
#SBATCH --error=${LOGDIR}/my_job_monan.e%j    # File name for standard error output

export executable=${EXPDIR}/atmosphere_model
cp -u ${EXECPATH}/atmosphere_model ${EXPDIR}

cd ${DIR_HOME}/run
. ${DIR_HOME}/run/load_monan_app_modules.sh

# generic
ulimit -c unlimited
ulimit -v unlimited
ulimit -s unlimited

cd ${EXPDIR}
cp -u ${SUBMIT_HOME}/${LABELI}/pre/runs/${EXP_NAME}/${AreaRegion}.${EXP_RES}.init.nc       ${SUBMIT_HOME}/${LABELI}/model/runs/${EXP_NAME}/
cp -u ${SUBMIT_HOME}/${LABELI}/pre/runs/${EXP_NAME}/${AreaRegion}.${EXP_RES}.sfc_update.nc ${SUBMIT_HOME}/${LABELI}/model/runs/${EXP_NAME}/
cp -u ${SUBMIT_HOME}/${LABELI}/pre/runs/${EXP_NAME}/lbc.*.nc                               ${SUBMIT_HOME}/${LABELI}/model/runs/${EXP_NAME}/                                     
echo \$SLURM_JOB_NUM_NODES

echo  "STARTING AT \`date\` "
Start=\`date +%s.%N\`
echo \$Start >  ${EXPDIR}/Timing

time mpirun -np \$SLURM_NTASKS -env UCX_NET_DEVICES=mlx5_0:1 -genvall \${executable}

End=\`date +%s.%N\`
echo  "FINISHED AT \`date\` "
echo \$End   >> ${EXPDIR}/Timing
echo \$Start \$End | awk '{print \$2 - \$1" sec"}' >>  ${EXPDIR}/Timing

if [ ! -e "${EXPDIR}/diag.${start_check}.nc" ]; then
    echo "********* ATENTION ************"
    echo "An error running MONAN occurred. check logs folder"
    echo "File ${EXPDIR}/${AreaRegion}.${EXP_RES}.init.nc was not generated."
    exit -1
fi
echo -e  "Script \${0} completed. \n"
  
#
# move dataout, clean up and remove files/links
#

cp ${AreaRegion}.*.init.nc* ${EXPDIR}/monanprd
mv diag* ${EXPDIR}/monanprd
mv histor* ${EXPDIR}/monanprd
mv Timing ${LOGDIR}/Timing.MONAN
find ${EXPDIR} -maxdepth 1 -type l -exec rm -f {} \;

exit 0
EOF0

chmod +x ${EXPDIR}/monan_exe.sh

export GREEN='\033[1;32m'  # Green
export NC='\033[0m'        # No Color

echo -e  "${GREEN}==>${NC} Submitting MONAN and waiting for finish before exit ... \n"
echo -e  "${GREEN}==>${NC} Logs being generated at ${SUBMIT_HOME}${LABELI}/model/runs/${EXP_NAME}/logs ... \n"
echo -e  "sbatch ${SUBMIT_HOME}/${LABELI}/model/runs/${EXP_NAME}/monan_exe.sh"
sbatch --wait ${EXPDIR}/monan_exe.sh

# output files are checked at monan_exe.sh

echo -e "${GREEN}==>${NC} Please, check the output log files at ${SUBMIT_HOME}/${LABELI}/model/runs/${EXP_NAME}/logs to be sure that MONAN ended successfully. \n"
echo -e "${GREEN}==>${NC} Script ${0} completed. \n"


}
