#!/bin/bash -x
function Function_static(){
#-----------------------------------------------------------------------------#
#BOP
#
# !SCRIPT: static
#
# !DESCRIPTION: Script para criar topografia, land use e variáveis estáticas
#
# !CALLING SEQUENCE:
#
#Function_static.sh ${RES_KM} ${EXP_NAME} ${EXP_RES}  ${LABELI} ${Domain} ${AreaRegion} ${TypeGrid}
#           o RES_KM     : 015_km
#           o EXP_NAME   : GFS, ERA5, CFSR, etc.
#           o EXP_RES    : 1024002 number of grid cel
#           o LABELI     : Initial: date 2015030600
#           o Domain     : global  or regional
#           o AreaRegion : PortoAlegre
#           o TypeGrid   : quasi_uniform or variable_resolution
#
# For benchmark:
#     ./static.sh 1024002 GFS 1024002
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

if [ $# -ne 7 ]; then
   usage
   exit 1
fi
#
# Args
#
   RES_KM=${1}
   EXP=${2}
   RES=${3}
   LABELI=${4}
   Domain=${5}
   AreaRegion=${6}
   TypeGrid=${7}
#
# Set Paths
#
#--- 
HSTMAQ=$(hostname)
#BASEDIR=$(dirname $(pwd))
BASEDIR=${SUBMIT_HOME}
DATADIR=${BASEDIR}/pre/databcs/
TBLDIR=${BASEDIR}/pre/tables
NMLDIR=${BASEDIR}/pre/namelist/${version_model}
MESHDIR=${BASEDIR}/pre/databcs/meshes/${TypeGrid}/${Domain}/${RES_KM}
GEODATA=${BASEDIR}/pre/databcs/WPS_GEOG/
EXECFILEPATH=${SUBMIT_HOME}/pre/exec
SCRIPTFILEPATH=${BASEDIR}/${LABELI}/pre/runs
STATICPATH=${SCRIPTFILEPATH}/${EXP}/static
#
# selected ncores to submission job
#
Function_SetClusterConfig ${EXP_RES} ${TypeGrid} 'set Function_SetClusterConfig '
#
# Criando diretorio dados Estaticos
#
if [ ! -e ${STATICPATH}/${AreaRegion}.${EXP_RES}.static.nc  ]; then
    echo "File does not exist."
else
    echo "File exists"
    return 44
fi

if [ ! -d ${STATICPATH} ]; then
  mkdir -p ${STATICPATH}/logs
fi

cd ${STATICPATH}

ln -sf ${TBLDIR}/* .

ln -sf ${MESHDIR}/${AreaRegion}.${RES}.grid.nc .

cp -f ${EXECFILEPATH}/init_atmosphere_model .

sed -e "s,#GEODAT#,${GEODATA},g;s,#RES#,${RES},g;s,#x1#,${AreaRegion},g" \
	${NMLDIR}/namelist.init_atmosphere.STATIC.${Domain} \
       > ${STATICPATH}/namelist.init_atmosphere

sed -e "s,#RES#,${RES},g;s,#x1#,${AreaRegion},g" \
       	${NMLDIR}/streams.init_atmosphere.STATIC.${Domain} \
	> ${STATICPATH}/streams.init_atmosphere


ln -sf ${MESHDIR}/${AreaRegion}.${RES}.graph.info.part.${cores_stat} .




cat > ${STATICPATH}/make_static.sh << EOF0
#!/bin/bash
#SBATCH --job-name=statdata
#SBATCH --nodes=1              # Specify number of nodes
#SBATCH --ntasks=${cores_stat}             
#SBATCH --tasks-per-node=128     # Specify number of (MPI) tasks on each node
#SBATCH --partition=batch
#SBATCH --time=02:00:00        # Set a limit on the total run time
#SBATCH --output=${STATICPATH}/logs/my_job.o%j    # File name for standard output
#SBATCH --error=${STATICPATH}/logs/my_job.e%j     # File name for standard error output

executable=init_atmosphere_model

ulimit -s unlimited
ulimit -c unlimited
ulimit -v unlimited

cd ${DIR_HOME}/run
. ${DIR_HOME}/run/load_monan_app_modules.sh

cd ${STATICPATH}

echo  "STARTING AT \`date\` "
Start=\`date +%s.%N\`
echo \$Start > ${STATICPATH}/Timing

date
time mpirun -np \$SLURM_NTASKS -env UCX_NET_DEVICES=mlx5_0:1 -genvall ./\${executable}

End=\`date +%s.%N\`
echo  "FINISHED AT \`date\` "
echo \$End   >> ${STATICPATH}/Timing
echo \$Start \$End | awk '{print \$2 - \$1" sec"}' >> ${STATICPATH}/Timing

grep "Finished running" log.init_atmosphere.0000.out >& /dev/null

if [ \$? -ne 0 ]; then
   echo "  BUMMER: Static generation failed for some yet unknown reason."
   echo " "
   tail -10 ${STATICPATH}/log.init_atmosphere.0000.out
   echo " "
   exit 21
else
   echo "  ####################################"
   echo "  ### Static completed - \$(date) ####"
   echo "  ####################################"
   echo " "
fi
#
# clean up and remove links
#

mv ${STATICPATH}/log.init_atmosphere.0000.out ${STATICPATH}/logs
mv ${STATICPATH}/Timing                       ${STATICPATH}/logs

find ${STATICPATH} -maxdepth 1 -type l -exec rm -f {} \;

date
exit 0
EOF0

chmod +x ${STATICPATH}/make_static.sh


echo -e  "${GREEN}==>${NC} Executing sbatch make_static.sh...\n"

cd ${STATICPATH}

echo sbatch --wait ${STATICPATH}/make_static.sh

sbatch --wait ${STATICPATH}/make_static.sh

if [ ! -e ${STATICPATH}/${AreaRegion}.${EXP_RES}.static.nc  ]; then
    echo "File does not exist."
    echo -e  "\n${RED}==>${NC} ***** ATTENTION *****\n"	
    echo -e  "${RED}==>${NC} Static phase fails ! Check logs at ${DIRMONAN_PRE_SCR}/${LABELI}/pre/runs/${EXP_NAME}/static/logs . Exiting script. \n"
    exit -1
else
    echo "File exists"
    echo "SUCCESS EXECUTION"
fi
}
