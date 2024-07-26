#!/bin/bash -x
function Function_Degrib_IC_ERA5(){
#-----------------------------------------------------------------------------#
#BOP
#
# !SCRIPT: static
#
# !DESCRIPTION: Script para criar topografia, land use e variáveis estáticas
#
# !CALLING SEQUENCE:
#
#Function_Degrib_IC.sh ${RES_KM} ${EXP_NAME} ${EXP_RES}  ${LABELI}  ${LABELF} ${Domain} ${AreaRegion} ${TypeGrid}
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
   RES=${3}
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
NMLDIR=${BASEDIR}/pre/namelist
EXPDIR=${RUNDIR}/${EXP}
LOGDIR=${EXPDIR}/logs
SCRDIR=${SUBMIT_HOME}/run/scripts
EXECPATH=${SUBMIT_HOME}/pre/exec
USERDATA=`echo ${EXP} | tr '[:upper:]' '[:lower:]'`

OPERDIR=${BASEDIR}/pre/datain/${Domain}/${USERDATA}
BNDDIR=$OPERDIR/${LABELI:0:10}
BNDDIR2=/oper/dados/ioper/tempo/NCEP/input/${LABELI:0:4}/${LABELI:4:2}/${LABELI:6:2}/00/

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
 Function_SetResolution ${RES} ${TypeGrid} 'set Function_SetClusterConfig '
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
#ln -sf ${BASEDIR}/${LABELI}/pre/runs/${EXP}/static/*.nc .
#
cd ${EXPDIR}/wpsprd

if [ ${Domain} = "global" ]; then
ln -sf ${BNDDIR}/*.grb .
ln -sf ${OPERDIR}/invariant/*.grb .
else
cdo sellonlatbox,260,350,-70,20 ${BNDDIR}/gfs.t00z.pgrb2.0p25.f000.${LABELI}.grib2  ${EXPDIR}/wpsprd/gfs.t00z.pgrb2.0p25.f000.${LABELI}.grib2
fi
#
#
# scripts
#
JobName=gfs4monan
#
#
#
cat > ${EXPDIR}/degrib_ic_exe.sh << EOF0
#!/bin/bash
#SBATCH --job-name=${JobName}
#SBATCH --nodes=1
#SBATCH --partition=batch
#SBATCH --tasks-per-node=1                      # ic for benchmark
#SBATCH --time=00:30:00
#SBATCH --output=${LOGDIR}/my_job_ungrib.o%j    # File name for standard output
#SBATCH --error=${LOGDIR}/my_job_ungrib.e%j     # File name for standard error output
#
ulimit -s unlimited
ulimit -c unlimited
ulimit -v unlimited

export PMIX_MCA_gds=hash

echo  "STARTING AT \`date\` "
Start=\`date +%s.%N\`
echo \$Start > Timing.degrib
#
cd ${EXPDIR}
 
ln -sf ${BASEDIR}/${LABELI}/pre/runs/${EXP}/static/${AreaRegion}.${RES}.static.nc .

cd ${EXPDIR}/wpsprd

#

echo "FORECAST "${LABELI}

cp ${TBLDIRGRIB}/Vtable.ERA-interim.pl ${EXPDIR}/wpsprd/Vtable

cp ${TBLDIRGRIB}/link_grib.csh ${EXPDIR}/wpsprd/link_grib.csh
chmod 777 ${EXPDIR}/wpsprd/link_grib.csh

cp ${EXECPATH}/ungrib.exe ${EXPDIR}/wpsprd/ungrib.exe

export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:${HOME}/local/lib64

ldd ungrib.exe

cd $EXPDIR/wpsprd 

if [ -e namelist.wps ]; then rm -f namelist.wps; fi
#
# invariant variables [ONLY FOR BENCHMARK]
#
# LSM
#
sed -e "s,#LABELI#,1979-01-01_00:00:00,g;s,#PREFIX#,LSM,g" \
	${NMLDIR}/namelist.wps.TEMPLATE.${Domain} > ./namelist.wps


${EXPDIR}/wpsprd/link_grib.csh \
	e5.oper.invariant.128_172_lsm.ll025sc.1979010100_1979010100.grb

mpirun -np 1 ./ungrib.exe
mv ungrib.log ungrib.lsm.log

#
# SOILGHT
# 
rm -f namelist.wps

sed -e "s,#LABELI#,1979-01-01_00:00:00,g;s,#PREFIX#,GEO,g" \
	${NMLDIR}/namelist.wps.TEMPLATE.${Domain} > ./namelist.wps

rm -f GRIBFILE.AAA
${EXPDIR}/wpsprd/link_grib.csh \
	e5.oper.invariant.128_129_z.ll025sc.1979010100_1979010100.grb

mpirun -np 1 ./ungrib.exe
mv ungrib.log ungrib.geo.log

#
# Now surface and upper air atmospheric variables
#
rm GRIBFILE.* namelist.wps

sed -e "s,#LABELI#,${start_date},g;s,#PREFIX#,FILE,g" \
	${NMLDIR}/namelist.wps.TEMPLATE.${Domain} > ./namelist.wps


${EXPDIR}/wpsprd/link_grib.csh e5.oper.an.*.grb

mpirun -np 1 ./ungrib.exe

echo ${start_date:0:13}

cat FILE\:${start_date:0:13} LSM\:1979-01-01_00 > FILE2:${start_date:0:13}
cat FILE2\:${start_date:0:13} GEO\:1979-01-01_00 > FILE3:${start_date:0:13}

rm -f GRIBFILE.*

End=\`date +%s.%N\`
echo  "FINISHED AT \`date\` "
echo \$End   >>Timing.degrib
echo \$Start \$End | awk '{print \$2 - \$1" sec"}' >> Timing.degrib

grep "Successful completion of program ungrib.exe" ungrib.log >& /dev/null

if [ \$? -ne 0 ]; then
   echo "  BUMMER: Ungrib generation failed for some yet unknown reason."
   echo " "
   tail -10 ${LOGDIR}/ungrib.log
   echo " "
   exit 21
fi
   echo "  ####################################"
   echo "  ### Ungrib completed - \$(date) ####"
   echo "  ####################################"
   echo " " 
#
# clean up and remove links
#
   mv ungrib.log ${LOGDIR}/ungrib.${start_date}.log
   mv Timing.degrib ${LOGDIR}
   mv namelist.wps degrib_ic_exe.sh ${EXPDIR}/scripts
   rm -f ${EXPDIR}/wpsprd/link_grib.csh
   cd ..
   ln -sf wpsprd/FILE3\:${start_date:0:13} .
   find ${EXPDIR}/wpsprd -maxdepth 1 -type l -exec rm -f {} \;

echo "End of degrib Job"


exit 0
EOF0

chmod +x ${EXPDIR}/degrib_ic_exe.sh


echo -e  "${GREEN}==>${NC} Submiting degrib_ic_exe.sh...\n"
mkdir -p ${HOME}/local/lib64
cp -f /usr/lib64/libjasper.so* ${HOME}/local/lib64
cp -f /usr/lib64/libjpeg.so* ${HOME}/local/lib64

cd ${DIRMONAN_PRE_SCR}/${LABELI}/pre/runs/${EXP_NAME}//wpsprd/

sbatch --wait ${EXPDIR}/degrib_ic_exe.sh

export start_date=${LABELI:0:4}-${LABELI:4:2}-${LABELI:6:2}_${LABELI:8:2}:00:00

files_ungrib=("LSM:${start_date:0:13}" "GEO:${start_date:0:13}" "FILE:${start_date:0:13}" "FILE2:${start_date:0:13}" "FILE3:${start_date:0:13}")

}
