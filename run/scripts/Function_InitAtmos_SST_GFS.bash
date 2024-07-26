#!/bin/bash -x
function Function_InitAtmos_SST_GFS(){
#-----------------------------------------------------------------------------#
#BOP
#
# !SCRIPT: static
#
# !DESCRIPTION: Script para criar topografia, land use e variáveis estáticas
#
# !CALLING SEQUENCE:
#
#Function_InitAtmos_IC_GFS.sh ${RES_KM} ${EXP_NAME} ${EXP_RES}  ${LABELI}  ${LABELF} ${Domain} ${AreaRegion} ${TypeGrid}
#           o RES_KM     : 015_km
#           o EXP_NAME   : GFS, ERA5, CFSR, etc.
#           o EXP_RES    : 1024002 number of grid cel
#           o LABELI     : Initial: date 2015030600
#           o LABELF     : End    : date 2015030600
#           o Domain     : global  or regional
#           o AreaRegion : PortoAlegre
#           o TypeGrid   : quasi_uniform or variable_resolution
#
# For benchmark:
#     ./Function_Degrib_IC.sh 1024002 GFS 1024002
#
# !REVISION HISTORY: 
#
# !REMARKS:
#
#EOP
#-----------------------------------------------------------------------------!
#EOC

function usage(){
   sed -n '/^# !CALLING SEQUENCE:/,/^# !/{p}' static.sh | head -n -1
}

#
# Check input args
#

if [ $# -ne 8 ]; then
   usage
   exit 1
fi
#
# Args
#
   RES_KM=${1}
   EXP=${2}
   EXP_RES=${3}
   LABELI=${4}
   LABELF=${5}
   Domain=${6}
   AreaRegion=${7}
   TypeGrid=${8}
   start_date=${LABELI:0:4}-${LABELI:4:2}-${LABELI:6:2}_${LABELI:8:2}:00:00
   end_date=${LABELF:0:4}-${LABELF:4:2}-${LABELF:6:2}_${LABELF:8:2}:00:00

#
# Set Paths
#
#--- 
HSTMAQ=$(hostname)
BASEDIR=${SUBMIT_HOME}
RUNDIR=${BASEDIR}/${LABELI}/pre/runs
TBLDIRGRIB=${SUBMIT_HOME}/pre/Variable_Tables
DIR_MESH=${SUBMIT_HOME}/pre/databcs/meshes/${TypeGrid}/${Domain}/${RES_KM}/
NMLDIR=${BASEDIR}/pre/namelist
EXPDIR=${RUNDIR}/${EXP}
LOGDIR=${EXPDIR}/logs
SCRDIR=${SUBMIT_HOME}/run/scripts
EXECPATH=${SUBMIT_HOME}/pre/exec
USERDATA=${EXP}
DATASST=${SUBMIT_HOME}/pre/databcs/datasst/bin
OPERDIR=/oper/dados/ioper/tempo/${EXP}
BNDDIR=$OPERDIR/0p25/brutos/${LABELI:0:4}/${LABELI:4:2}/${LABELI:6:2}/${LABELI:8:2}

echo $BNDDIR

if [ ! -d ${BNDDIR} ]; then
   echo "Condicao de contorno inexistente !"
   echo "Verifique a data da rodada."
   echo "$0 ${LABELI}"
   exit 1                     # close for running only the model
fi
#
# selected ncores to submission job
#
Function_SetClusterConfig ${EXP_RES} ${TypeGrid} 'set Function_SetClusterConfig '

#
# Criando diretorio dados Estaticos
#
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
if [  -e ${EXPDIR} ]; then
   mkdir -p ${EXPDIR}
   mkdir -p ${EXPDIR}/logs   
   mkdir -p ${EXPDIR}/sst
   mkdir -p ${EXPDIR}/wpsprd
   mkdir -p ${EXPDIR}/scripts
fi
#
#
# scripts
#
JobName=gfs4monan
#
#
#
###############################################################################
cd ${DIRMONAN_PRE_SCR}/${LABELI}/pre/runs/${EXP_NAME}

###############################################################################
#
#             Boundary conditions (SST) for MONAN grid
#
###############################################################################

cd ${EXPDIR}

JobName=sst_monan

cat > InitAtmosSST_exe.sh <<EOF0
#!/bin/bash
#SBATCH --job-name=${JobName}
#SBATCH --nodes=${nodes}             # Specify number of nodes
#SBATCH --ntasks=${cores}             
#SBATCH --tasks-per-node=128     # Specify number of (MPI) tasks on each node
#SBATCH --partition=batch 
#SBATCH --time=${JobElapsedTime}
#SBATCH --output=${LOGDIR}/my_job_ic.o%j    # File name for standard output
#SBATCH --error=${LOGDIR}/my_job_ic.e%j     # File name for standard error output
#

export executable=init_atmosphere_model

ulimit -c unlimited
ulimit -v unlimited
ulimit -s unlimited

cd ${DIR_HOME}/run
. ${DIR_HOME}/run/load_monan_app_modules.sh

cd ${EXPDIR}

# namelist

sed -e "s,#LABELI#,${start_date},g;s,#LABELF#,${end_date},g;s,#RESNPTS#,${EXP_RES},g;s,#x1#,${AreaRegion},g" \
	 ${NMLDIR}/namelist.init_atmosphere.SST.${Domain} > ./namelist.init_atmosphere

sed -e "s,#RESNPTS#,${EXP_RES},g;s,#x1#,${AreaRegion},g" \
	 ${NMLDIR}/streams.init_atmosphere.SST.${Domain} > ./streams.init_atmosphere

ln -sf ${DIR_MESH}/${AreaRegion}.${EXP_RES}.graph.info.part.${cores} .

rm -f ${AreaRegion}.${EXP_RES}.sfc_update.nc


# executable

cp -f ${EXECPATH}/init_atmosphere_model init_atmosphere_model

echo  "STARTING AT \`date\` "
Start=\`date +%s.%N\`
echo \$Start >  ${EXPDIR}/Timing.InitAtmosSST

time mpirun -np \$SLURM_NTASKS -env UCX_NET_DEVICES=mlx5_0:1 -genvall ./\${executable}

End=\`date +%s.%N\`
echo  "FINISHED AT \`date\` "
echo \$End   >> ${EXPDIR}/Timing.InitAtmosSST
echo \$Start \$End | awk '{print \$2 - \$1" sec"}' >>  ${EXPDIR}/Timing.InitAtmosSST

rm -f SST:*

date
exit 0
EOF0

chmod +x InitAtmosSST_exe.sh

echo -e  "${GREEN}==>${NC} Submiting InitAtmosSST_exe.sh...\n"
cd  ${DIRMONAN_PRE_SCR}/${LABELI}/pre/runs/${EXP_NAME}

sbatch --wait ${EXPDIR}/InitAtmosSST_exe.sh
echo -e  "${GREEN}==>${NC} Script ${0} completed. \n"


grep "ERROR:" ${EXPDIR}/log.init_atmosphere.0000.out >& /dev/null

if [ $? -eq 0 ]; then
   echo "  BUMMER: Ungrib generation failed for some yet unknown reason."
   echo " "
   tail -30 ${EXPDIR}/log.init_atmosphere.0000.out
   echo " "
   exit 21
fi

}
