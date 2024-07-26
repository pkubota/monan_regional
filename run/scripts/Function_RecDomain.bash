#!/bin/bash +x
function Function_RecDomain(){
#-----------------------------------------------------------------------------#
#BOP
#
# !SCRIPT: Function_RecDomain
#
# !DESCRIPTION: Script para criar topografia, land use e variáveis estáticas
#
# !CALLING SEQUENCE:
#
#Function_RecDomain.sh ${RES_KM} ${EXP_RES} ${frac} ${Domain} ${AreaRegion} ${TypeGrid}
#           o RES_KM     : 015_km
#           o Domain     : global  or regional
#           o AreaRegion : PortoAlegre
#           o TypeGrid   : quasi_uniform or variable_resolution
#
# For benchmark:
#     ./Function_RecDomain.sh 1024002 GFS 1024002
#
# !REVISION HISTORY: 
#
# !REMARKS:
#
#EOP
#-----------------------------------------------------------------------------!
#EOC

function usage(){
   sed -n '/^# !CALLING SEQUENCE:/,/^# !/{p}' Function_RecDomain.bash | head -n -1
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

if [ ${TypeGrid} = "variable_resolution" ]; then
  echo "-------------------------------------------"  
  echo "       RESOLUTION VARIABLE_RESOLUTION      "  
  echo "-------------------------------------------"  
  return 42
fi
cd ${SUBMIT_HOME}/pre/databcs/meshes/${TypeGrid}/
path_rec=${SUBMIT_HOME}"/pre/databcs/meshes/regional_domain/"

if [ ${Domain} = "regional" ]; then
echo "----------------------------"  
echo "       REGIONAL DOMAIN      "  
echo "----------------------------"  


#$ create_region           points        grid

create_region     ${path_rec}/${AreaRegion}.ellipse.pts     global/${RES_KM}/x${frac}.${EXP_RES}.grid.nc

mkdir -p regional/${RES_KM}/

mv ${AreaRegion}.graph.info  regional/${RES_KM}/${AreaRegion}.${EXP_RES}.graph.info
mv ${AreaRegion}.grid.nc     regional/${RES_KM}/${AreaRegion}.${EXP_RES}.grid.nc

${path_mets}/gpmetis     -minconn     -contig    -niter=1000    regional/${RES_KM}/${AreaRegion}.${EXP_RES}.graph.info    128
${path_mets}/gpmetis     -minconn     -contig    -niter=1000    regional/${RES_KM}/${AreaRegion}.${EXP_RES}.graph.info    32
${path_mets}/gpmetis     -minconn     -contig    -niter=1000    regional/${RES_KM}/${AreaRegion}.${EXP_RES}.graph.info    256
${path_mets}/gpmetis     -minconn     -contig    -niter=1000    regional/${RES_KM}/${AreaRegion}.${EXP_RES}.graph.info    512
else
echo "----------------------------"  
echo "        GLOBAL DOMAIN       "  
echo "----------------------------"  
ln global/${RES_KM}/x${frac}.${EXP_RES}.graph.info  global/${RES_KM}/${AreaRegion}.${EXP_RES}.graph.info
ln global/${RES_KM}/x${frac}.${EXP_RES}.grid.nc     global/${RES_KM}/${AreaRegion}.${EXP_RES}.grid.nc

${path_mets}/gpmetis     -minconn     -contig    -niter=1000    global/${RES_KM}/${AreaRegion}.${EXP_RES}.graph.info    128
${path_mets}/gpmetis     -minconn     -contig    -niter=1000    global/${RES_KM}/${AreaRegion}.${EXP_RES}.graph.info    32
${path_mets}/gpmetis     -minconn     -contig    -niter=1000    global/${RES_KM}/${AreaRegion}.${EXP_RES}.graph.info    256
${path_mets}/gpmetis     -minconn     -contig    -niter=1000    global/${RES_KM}/${AreaRegion}.${EXP_RES}.graph.info    512
fi
}
