#!/bin/bash +x
function Function_GridRotate(){
#-----------------------------------------------------------------------------#
#BOP
#
# !SCRIPT: Function_RecDomain
#
# !DESCRIPTION: Script para criar topografia, land use e variáveis estáticas
#
# !CALLING SEQUENCE:
#
#Function_GridRotate.sh ${RES_KM} ${EXP_RES} ${frac} ${Domain} ${AreaRegion} ${TypeGrid}
#           o RES_KM     : 015_km
#           o Domain     : global  or regional
#           o AreaRegion : PortoAlegre
#           o TypeGrid   : quasi_uniform or variable_resolution
#
# For benchmark:
#     ./Function_GridRotate.sh 1024002 GFS 1024002
#
# !REVISION HISTORY: 
#
# !REMARKS:
#
#EOP
#-----------------------------------------------------------------------------!
#EOC

function usage(){
   sed -n '/^# !CALLING SEQUENCE:/,/^# !/{p}' Function_GridRotate.bash | head -n -1
}

#
# Check input args
#

if [ $# -ne 6 ]; then
   usage
   exit 1
fi
RES_KM=${1}
EXP_RES=${2}
frac=${3}
Domain=${4}
AreaRegion=${5}
TypeGrid=${6}


if [ ${TypeGrid} = 'variable_resolution' ]; then
path_exe=${SUBMIT_HOME}"/pre/databcs/meshes/"${TypeGrid}
path_rec=${SUBMIT_HOME}"/pre/databcs/meshes/regional_domain/"
path_bin=${SUBMIT_HOME}"/pre/sources/MPAS-Tools/MPAS-Limited-Area/"
path_in=${path_exe}
path_out=${path_exe}
input_filename=${path_exe}/global/${RES_KM}/x${frac}.${EXP_RES}.grid.nc
output_filename=./global/${RES_KM}/g${frac}.${EXP_RES}.grid.nc

cd ${path_exe}
clon=`cat ${path_rec}/${AreaRegion}.ellipse.pts | grep Point: | awk '{printf "%.5f\n", $3/1}'`
clat=`cat ${path_rec}/${AreaRegion}.ellipse.pts | grep Point: | awk '{printf "%.5f\n", $2/1}'`

cat<<EOF>${path_exe}/namelist.input
&input
   config_original_latitude_degrees = 0
   config_original_longitude_degrees = 0

   config_new_latitude_degrees = ${clat}
   config_new_longitude_degrees = ${clon}
   config_birdseye_rotation_counter_clockwise_degrees = 0
/
EOF

${SUBMIT_HOME}/pre/exec/grid_rotate ${input_filename} ${output_filename}

rm -f ${path_exe}/namelist.input

if [ ${Domain} = "regional" ]; then
echo "----------------------------"  
echo "       REGIONAL DOMAIN      "  
echo "----------------------------"  

echo create_region     ${path_rec}/${AreaRegion}.ellipse.pts     global/${RES_KM}/g${frac}.${EXP_RES}.grid.nc
chmod 777 ${path_bin}/create_region

${path_bin}/create_region          ${path_rec}/${AreaRegion}.ellipse.pts     global/${RES_KM}/g${frac}.${EXP_RES}.grid.nc

mkdir -p regional/${RES_KM}/

mv ${AreaRegion}.graph.info  regional/${RES_KM}/${AreaRegion}.${EXP_RES}.graph.info
mv ${AreaRegion}.grid.nc     regional/${RES_KM}/${AreaRegion}.${EXP_RES}.grid.nc

path_mets=/mnt/beegfs/paulo.kubota/monan_project/metis-5.1.0/build/Linux-x86_64/programs
${path_mets}/gpmetis     -minconn     -contig    -niter=1000    regional/${RES_KM}/${AreaRegion}.${EXP_RES}.graph.info    128
${path_mets}/gpmetis     -minconn     -contig    -niter=1000    regional/${RES_KM}/${AreaRegion}.${EXP_RES}.graph.info    32
${path_mets}/gpmetis     -minconn     -contig    -niter=1000    regional/${RES_KM}/${AreaRegion}.${EXP_RES}.graph.info    256
${path_mets}/gpmetis     -minconn     -contig    -niter=1000    regional/${RES_KM}/${AreaRegion}.${EXP_RES}.graph.info    512
else

ln global/${RES_KM}/x${frac}.${EXP_RES}.graph.info   global/${RES_KM}/${AreaRegion}.${EXP_RES}.graph.info
ln global/${RES_KM}/g${frac}.${EXP_RES}.grid.nc      global/${RES_KM}/${AreaRegion}.${EXP_RES}.grid.nc

path_mets=/mnt/beegfs/paulo.kubota/monan_project/metis-5.1.0/build/Linux-x86_64/programs
${path_mets}/gpmetis     -minconn     -contig    -niter=1000    global/${RES_KM}/${AreaRegion}.${EXP_RES}.graph.info    128
${path_mets}/gpmetis     -minconn     -contig    -niter=1000    global/${RES_KM}/${AreaRegion}.${EXP_RES}.graph.info    32
${path_mets}/gpmetis     -minconn     -contig    -niter=1000    global/${RES_KM}/${AreaRegion}.${EXP_RES}.graph.info    256
${path_mets}/gpmetis     -minconn     -contig    -niter=1000    global/${RES_KM}/${AreaRegion}.${EXP_RES}.graph.info    512

echo "----------------------------"  
echo "        GLOBAL DOMAIN       "  
echo "----------------------------"  
fi

else
  echo "-------------------------------------"  
  echo "       RESOLUTION QUASI_UNIFORM      "  
  echo "-------------------------------------"  
  return 40
fi
}
