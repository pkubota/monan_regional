
# Define a function with local variables

Function_RunPost() {
#-----------------------------------------------------------------------------#
#                                   DIMNT/INPE                                #
#-----------------------------------------------------------------------------#
#BOP
#
# !SCRIPT: Function_RunPost
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
#        ./Function_RunPost.bash EXP_NAME RES LABELI
#
# For benchmark:
#        ./Function_RunPost.bash CFSR ${EXP_RES} 2010102300
#
# For ERA5 datasets
#
#        ./Function_RunPost.bash ERA5 ${EXP_RES} 2021010100
#        ./Function_RunPost  ${RES_KM} ${EXP_NAME} ${EXP_RES} ${LABELI} ${LABELF}  ${Domain} ${AreaRegion} ${TypeGrid}
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
   sed -n '/^# !CALLING SEQUENCE:/,/^# !/{p}' ./scripts/Function_RunPost.bash | head -n -1
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

if [ ${Domain} = "regional" ]; then
echo "----------------------------"  
echo "       REGIONAL DOMAIN      "  
echo "----------------------------"  

export DIR_MESH=${SUBMIT_HOME}/pre/databcs/meshes/regional_domain/


clon=`cat ${DIR_MESH}/${AreaRegion}.ellipse.pts | grep Point: | awk '{printf "%.5f\n", $3/1}'`
clat=`cat ${DIR_MESH}/${AreaRegion}.ellipse.pts | grep Point: | awk '{printf "%.5f\n", $2/1}'`
#
#   1grau -  110000
#   y     - 1000000.   
#
Semi_major_axis=`cat ${DIR_MESH}/${AreaRegion}.ellipse.pts | grep Semi-major-axis: | awk '{printf "%.5f\n", (($2/1)/100000)+2}'`
startlon=`echo ${clon}  ${Semi_major_axis}| awk '{printf "%.5f\n", $1-(($2/2)+7)} '`   # -64.0
endlon=`echo   ${clon}  ${Semi_major_axis}| awk '{printf "%.5f\n", $1+(($2/2)+7)} '`   # -39.0
startlat=`echo ${clat}  ${Semi_major_axis}| awk '{printf "%.5f\n", $1-(($2/2)+7)} '`   # -40.0
endlat=`echo ${clat}    ${Semi_major_axis}| awk '{printf "%.5f\n", $1+(($2/2)+7)} '`   # -20.0
nlat=`echo ${startlat}  ${endlat} ${len_disp}| awk '{printf "%d\n", sqrt(((($2-$1+1)*110000)/$3)^2) } '`    # 700
nlon=`echo ${startlon}  ${endlon} ${len_disp}| awk '{printf "%d\n", sqrt(((($2-$1+1)*110000)/$3)^2) } '`    #  867

else
echo "----------------------------"  
echo "        GLOBAL DOMAIN       "  
echo "----------------------------"  
#Semi_major_axis=`cat ${DIR_MESH}/${AreaRegion}.ellipse.pts | grep Semi-major-axis: | awk '{printf "%.5f\n", (($2/1)/100000)+2}'`
startlon=0.2496533   #`echo ${clon}  ${Semi_major_axis}| awk '{printf "%.5f\n", $1-(($2/2)+7)} '`   # -64.0
endlon=359.7503   #`echo   ${clon}  ${Semi_major_axis}| awk '{printf "%.5f\n", $1+(($2/2)+7)} '`   # -39.0
startlat=-89.75 #`echo ${clat}  ${Semi_major_axis}| awk '{printf "%.5f\n", $1-(($2/2)+7)} '`   # -40.0
endlat=89.75    #`echo ${clat}    ${Semi_major_axis}| awk '{printf "%.5f\n", $1+(($2/2)+7)} '`   # -20.0
nlat=360 #`echo ${startlat}  ${endlat} ${len_disp}| awk '{printf "%d\n", sqrt(((($2-$1+1)*110000)/$3)^2) } '`    # 700
nlon=721 #`echo ${startlon}  ${endlon} ${len_disp}| awk '{printf "%d\n", sqrt(((($2-$1+1)*110000)/$3)^2) } '`    #  867
fi

mkdir -p ${SUBMIT_HOME}/${LABELI}/pos/runs/${EXP_NAME}/postprd/logs
mkdir -p ${SUBMIT_HOME}/${LABELI}/pos/runs/${EXP_NAME}/monanprd

cat <<EOF2>${SUBMIT_HOME}/${LABELI}/pos/runs/${EXP_NAME}/postprd//target_domain
nlat = ${nlat}
nlon = ${nlon}
startlat = ${startlat}
startlon = ${startlon}
endlat   = ${endlat}
endlon   = ${endlon}
EOF2

echo -e  "\n${GREEN}==>${NC} Executing post processing...\n"
LOGDIR=${SUBMIT_HOME}/${LABELI}/pos/runs/${EXP_NAME}/postprd/logs
LOG_FILE=${LOGDIR}/pos.out
rm -f ${LOG_FILE}

# copy convert_mpas from MONAN/exec to testcase
cd ${SUBMIT_HOME}/${LABELI}/pos/runs/${EXP_NAME}/postprd
rm -f ${SUBMIT_HOME}/${LABELI}/pos/runs/${EXP_NAME}/postprd/convert_mpas >> ${LOG_FILE}
cp ${DIR_HOME}/pos/exec/${version_pos}/exec/convert_mpas ${SUBMIT_HOME}/${LABELI}/pos/runs/${EXP_NAME}/postprd/ >> ${LOG_FILE}

cp -u ${SUBMIT_HOME}/${LABELI}/model/runs/${EXP_NAME}/${AreaRegion}.${EXP_RES}.init.nc        ${SUBMIT_HOME}/${LABELI}/model/runs/${EXP_NAME}/monanprd/ >> ${LOG_FILE}
# copy from repository to testcase and runs /ngrid2latlon.sh
cp ${SUBMIT_HOME}/pos/namelist/${version_pos}/convert_mpas.nml ${SUBMIT_HOME}/${LABELI}/pos/runs/${EXP_NAME}/postprd/convert_mpas.nml   >> ${LOG_FILE}
cp ${SUBMIT_HOME}/pos/namelist/${version_pos}/ctl_descriptor.bash      ${SUBMIT_HOME}/${LABELI}/pos/runs/${EXP_NAME}/postprd/ctl_descriptor.bash >> ${LOG_FILE}

cd ${SUBMIT_HOME}/${LABELI}/pos/runs/${EXP_NAME}/postprd/ 

#
#
# scripts
#
JobName=post_monan
#
#

cat > post_convert.sh << EOF0
#!/bin/bash
#SBATCH --job-name=${JobName}
#SBATCH --nodes=1
#SBATCH --partition=batch
#SBATCH --tasks-per-node=1                      # ic for benchmark
#SBATCH --time=04:30:00
#SBATCH --output=${LOGDIR}/my_job_postprd.o%j    # File name for standard output
#SBATCH --error=${LOGDIR}/my_job_postprd.e%j     # File name for standard error output
#
ulimit -s unlimited
ulimit -c unlimited
ulimit -v unlimited

export PMIX_MCA_gds=hash

echo  "STARTING AT \`date\` "
#
cd ${SUBMIT_HOME}/${LABELI}/pos/runs/${EXP_NAME}/postprd/ 

search_dir=${SUBMIT_HOME}/${LABELI}/model/runs/${EXP_NAME}/monanprd
for files in "\$search_dir"/diag.*
do

dirpost=`pwd`
dirmodel=\`dirname \${files}\`
filename=\`basename \${files}\`
if [ \${filename:0:4} = "diag" ]; then
labelF=\`echo \${filename} | awk '{print substr(\$1,6,22)}'\`
cp ${SUBMIT_HOME}/pos/namelist/${version_pos}/include_fields.diag      ${SUBMIT_HOME}/${LABELI}/pos/runs/${EXP_NAME}/postprd/include_fields   >> ${LOG_FILE}
cp ${SUBMIT_HOME}/pos/namelist/${version_pos}/exclude_fields.diag      ${SUBMIT_HOME}/${LABELI}/pos/runs/${EXP_NAME}/postprd/exclude_fields   >> ${LOG_FILE}

else
labelF=\`echo \${filename} | awk '{print substr(\$1,9,22)}'\`
cp ${SUBMIT_HOME}/pos/namelist/${version_pos}/include_fields.history      ${SUBMIT_HOME}/${LABELI}/pos/runs/${EXP_NAME}/postprd/include_fields   >> ${LOG_FILE}
cp ${SUBMIT_HOME}/pos/namelist/${version_pos}/exclude_fields.history      ${SUBMIT_HOME}/${LABELI}/pos/runs/${EXP_NAME}/postprd/exclude_fields   >> ${LOG_FILE}
fi
postname='mpas.'\${labelF}
rm latlon.nc
./convert_mpas \${search_dir}/${AreaRegion}.${EXP_RES}.init.nc  \${dirmodel}/\${filename}
mv latlon.nc  \${postname}
done

echo "End of degrib Job"

exit 0
EOF0

chmod 777 post_convert.sh

cd ${SUBMIT_HOME}/${LABELI}/pos/runs/${EXP_NAME}/postprd/ 


sbatch --wait post_convert.sh

echo Function_Create_ctl ${EXP_NAME} ${EXP_RES}  ${LABELI} ${Domain} ${AreaRegion} ${len_disp}

Function_Create_ctl ${EXP_NAME} ${EXP_RES}  ${LABELI} ${Domain} ${AreaRegion} ${len_disp}

echo -e  "${GREEN}==>${NC}  Script ${0} completed. \n"
echo -e  "${GREEN}==>${NC}  Log file: ${LOG_FILE} . End of script. \n"

}
