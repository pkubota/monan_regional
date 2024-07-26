#!/bin/bash -x
function Function_Create_ctl() {
#-----------------------------------------------------------------------------#
#                                   DIMNT/INPE                                #
#-----------------------------------------------------------------------------#
#BOP
#
# !SCRIPT: Function_Create_ctl
#
# !DESCRIPTION:
#        Script para rodar o Post-Processing of MONAN
#        Realiza as seguintes tarefas:
#           o Pos-processamento (netcdf para grib2, regrid latlon, crop)
#
# For GFS datasets
#
#        ./Function_Create_ctl.bash  GFS 535554   2024042700  
#           o EXP_NAME   : Forcing: ERA5, CFSR, GFS, etc.
#           o EXP_RES    : mesh npts : 535554 etc
#           o LABELI     : Initial: date 2015030600
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
   sed -n '/^# !CALLING SEQUENCE:/,/^# !/{p}' ./Function_Create_ctl.bash | head -n -1
}

#
# Verificando argumentos de entrada
#
echo $#

if [ $# -ne 6 ]; then
   usage
   exit 1
fi

echo 'aa'
echo ${1}
EXP_NAME=${1}
EXP_RES=${2}
LABELI=${3} 
Domain=${4} 
AreaRegion=${5}
len_disp=${6}


pathin=${SUBMIT_HOME}/${LABELI}/pos/runs/${EXP_NAME}/postprd
pathmesh=${SUBMIT_HOME}


MON=${LABELI:4:2}
case "`echo ${MON} | awk '{print $1/1 }'`" in
     1)CMON="Jan" ;;
     2)CMON="Feb" ;;
     3)CMON="Mar" ;;
     4)CMON="Apr" ;;
     5)CMON="May" ;;
     6)CMON="Jun" ;;
     7)CMON="Jul" ;;
     8)CMON="Aug" ;;
     9)CMON="Sep" ;;
    10)CMON="Oct" ;;
    11)CMON="Nov" ;;
    12)CMON="Dec" ;;
esac
echo $CMON

start_date=${LABELI:8:2}:00Z${LABELI:6:2}${CMON}${LABELI:0:4}
if [ ${Domain} = "regional" ]; then
echo "----------------------------"  
echo "       REGIONAL DOMAIN      "  
echo "----------------------------"  

ncdump -v longitude mpas.${LABELI:0:4}-${LABELI:4:2}-${LABELI:6:2}_${LABELI:8:2}.00.00.nc > ${pathin}/file.tmp0
aa=`cat -n ${pathin}/file.tmp0 | grep data: | awk '{print $1}' | bc -l`
nn=`a=$(cat ${pathin}/file.tmp0 | wc -l) && b=$(cat -n ${pathin}/file.tmp0 | grep data: | awk '{print $1}') && echo "$a - $b -1" | bc -l`
bb=`a=$(cat ${pathin}/file.tmp0 | wc -l) && b=$(cat -n ${pathin}/file.tmp0 | grep data: | awk '{print $1}') && echo "$a - $b -2" | bc -l`
tail -n $nn  ${pathin}/file.tmp0 > ${pathin}/file.tmp1
head -n $bb  ${pathin}/file.tmp1 > ${pathin}/file.tmp2
coma=","
blanck=" "
sed 's/,/ /g;s/longitude/ /g;s/=/ /g' ${pathin}/file.tmp2 > ${pathin}/longitude.tmp


ncdump -v latitude mpas.${LABELI:0:4}-${LABELI:4:2}-${LABELI:6:2}_${LABELI:8:2}.00.00.nc > ${pathin}/file.tmp0
aa=`cat -n ${pathin}/file.tmp0 | grep data: | awk '{print $1}' | bc -l`
nn=`a=$(cat ${pathin}/file.tmp0 | wc -l) && b=$(cat -n ${pathin}/file.tmp0 | grep data: | awk '{print $1}') && echo "$a - $b -1" | bc -l`
bb=`a=$(cat ${pathin}/file.tmp0 | wc -l) && b=$(cat -n ${pathin}/file.tmp0 | grep data: | awk '{print $1}') && echo "$a - $b -2" | bc -l`
tail -n $nn  ${pathin}/file.tmp0 > ${pathin}/file.tmp1
head -n $bb  ${pathin}/file.tmp1 > ${pathin}/file.tmp2
coma=","
blanck=" "
sed 's/,/ /g;s/latitude/ /g;s/=/ /g' ${pathin}/file.tmp2 > ${pathin}/latitude.tmp
echo $nn $aa
echo $nn $aa

export DIR_MESH=${pathmesh}/pre/databcs/meshes/regional_domain/
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
ncdump -v longitude mpas.${LABELI:0:4}-${LABELI:4:2}-${LABELI:6:2}_${LABELI:8:2}.00.00.nc > ${pathin}/file.tmp0
aa=`cat -n ${pathin}/file.tmp0 | grep data: | awk '{print $1}' | bc -l`
nn=`a=$(cat ${pathin}/file.tmp0 | wc -l) && b=$(cat -n ${pathin}/file.tmp0 | grep data: | awk '{print $1}') && echo "$a - $b -1" | bc -l`
bb=`a=$(cat ${pathin}/file.tmp0 | wc -l) && b=$(cat -n ${pathin}/file.tmp0 | grep data: | awk '{print $1}') && echo "$a - $b -2" | bc -l`
tail -n $nn  ${pathin}/file.tmp0 > ${pathin}/file.tmp1
head -n $bb  ${pathin}/file.tmp1 > ${pathin}/file.tmp2
coma=","
blanck=" "
sed 's/,/ /g;s/longitude/ /g;s/=/ /g' ${pathin}/file.tmp2 > ${pathin}/longitude.tmp


ncdump -v latitude mpas.${LABELI:0:4}-${LABELI:4:2}-${LABELI:6:2}_${LABELI:8:2}.00.00.nc > ${pathin}/file.tmp0
aa=`cat -n ${pathin}/file.tmp0 | grep data: | awk '{print $1}' | bc -l`
nn=`a=$(cat ${pathin}/file.tmp0 | wc -l) && b=$(cat -n ${pathin}/file.tmp0 | grep data: | awk '{print $1}') && echo "$a - $b -1" | bc -l`
bb=`a=$(cat ${pathin}/file.tmp0 | wc -l) && b=$(cat -n ${pathin}/file.tmp0 | grep data: | awk '{print $1}') && echo "$a - $b -2" | bc -l`
tail -n $nn  ${pathin}/file.tmp0 > ${pathin}/file.tmp1
head -n $bb  ${pathin}/file.tmp1 > ${pathin}/file.tmp2
coma=","
blanck=" "
sed 's/,/ /g;s/latitude/ /g;s/=/ /g' ${pathin}/file.tmp2 > ${pathin}/latitude.tmp
echo $nn $aa
echo $nn $aa
#
#   1grau -  110000
#   y     - 1000000.
#
nlat=`ncdump -c mpas.${LABELI:0:4}-${LABELI:4:2}-${LABELI:6:2}_${LABELI:8:2}.00.00.nc | head -n 6| grep latitude | awk '{print $3}'`
nlon=`ncdump -c mpas.${LABELI:0:4}-${LABELI:4:2}-${LABELI:6:2}_${LABELI:8:2}.00.00.nc | head -n 6| grep longitude | awk '{print $3}'`

fi
cat<<EOF1>${pathin}/file.ctl
DSET ^mpas.%y4-%m2-%d2_%h2.00.00.nc

DTYPE netcdf

Options zrev template

TITLE Ocean Surface Variables

UNDEF 9.96921e+36

*UNPACK scale_factor add_offset

XDEF ${nlon} levels

YDEF ${nlat} levels

ZDEF 27 levels 100000.0 97500.0  95000.0  92500.0  90000.0  87500.0  85000.0  82500.0  80000.0
                77500.0 75000.0  70000.0  65000.0  60000.0  55000.0  50000.0  45000.0  40000.0
	        35000.0 30000.0  25000.0  22500.0  20000.0  17500.0  15000.0  12500.0  10000.0
		
tdef  10000 linear ${start_date} 1hr
VARS 73
mslp=>psnm                  0 t,y,x   Mean sea-level pressure [Pa]
t_isobaric=>temp           27 t,z,y,x Temperature interpolated to isobaric surfaces [K]
atmt_isobaric=>atmt        27 t,z,y,x Temperature interpolated to isobaric surfaces [K]
w_isobaric=>wvel           27 t,z,y,x Vertical wind interpolated to isobaric surfaces [m/s]
ommt_isobaric=>ommt        27 t,z,y,x Vertical wind interpolated to isobaric surfaces [m/s]
ghmt_isobaric=>ghmt        27 t,z,y,x Geopotential height interpolated to isobaric surfaces [m]
zgeo_isobaric=>zgeo        27 t,z,y,x Geopotential height interpolated to isobaric surfaces [m]
vvel_isobaric=>vvel        27 t,z,y,x Meridional wind interpolated to isobaric surfaces[m/s]
vvmt_isobaric=>vvmt        27 t,z,y,x Meridional wind interpolated to isobaric surfaces[m/s]
uvel_isobaric=>uvel        27 t,z,y,x Zonal wind interpolated to isobaric surfaces[m/s]  
uvmt_isobaric=>uvmt        27 t,z,y,x Zonal wind interpolated to isobaric surfaces[m/s]  
qv_isobaric=>umes          27 t,z,y,x Water vapor mixing ratio interpolated to isobaric surfaces [kg/kg]
shmt_isobaric=>shmt        27 t,z,y,x Water vapor mixing ratio interpolated to isobaric surfaces [kg/kg]
rthblten_isobaric=>tpbl    27 t,z,y,x tendency of potential temperature due to pbl processes interpolated to isobaric surfaces [K/s]   
rthratensw_isobaric=>tswd  27 t,z,y,x tendency of potential temperature due to short wave radiation interpolated to isobaric surfaces [K/s]  
rthratenlw_isobaric=>tlwd  27 t,z,y,x tendency of potential temperature due to long wave radiation interpolated to isobaric surfaces [K/s] 
cldfrac_isobaric=>vdcc     27 t,z,y,x Cloud fraction interpolated to isobaric surfaces 
t2m=>t2m                    0   t,y,x 2-meter temperature  [K]
q2=>q2m                     0   t,y,x 2-meter specific humidity [kg/kg]
v10=>v10m                   0   t,y,x 10-meter meridional wind[m/s]
u10=>u10m                   0   t,y,x 10-meter zonal wind [m/s]
precipw=>agpl               0   t,y,x precipitable water [kg/m²]
aclwuptc=>aclwuptc          0   t,y,x accumulated clear-sky upward top-of-the-atmosphere longwave radiation flux [W/m²]
aclwupt=>aclwupt            0   t,y,x accumulated all-sky upward top-of-the-atmosphere longwave radiation flux  [W/m²]
aclwupbc=>aclwupbc          0   t,y,x accumulated clear-sky upward surface longwave radiation flux[W/m²]
aclwupb=>aclwupb            0   t,y,x accumulated all-sky upward surface longwave radiation flux [W/m²]
aclwdntc=>aclwdntc          0   t,y,x accumulated clear-sky downward top-of-the-atmosphere longwave radiation flux[W/m²]
aclwdnt=>aclwdnt            0   t,y,x accumulated all-sky downward top-of-the-atmosphere longwave radiation flux [W/m²]
aclwdnbc=>aclwdnbc          0   t,y,x accumulated clear-sky downward surface longwave radiation flux[W/m²]
aclwdnb=>aclwdnb            0   t,y,x accumulated all-sky downward surface longwave radiation flux[W/m²]
acswuptc=>acswuptc          0   t,y,x accumulated clear-sky upward top-of-atmosphere shortwave radiation flux[W/m²]
acswupt=>acswupt            0   t,y,x accumulated all-sky upward top-of-atmosphere shortwave radiation flux [W/m²]
acswupbc=>acswupbc          0   t,y,x accumulated clear-sky upward surface shortwave radiation flux[W/m²]
acswupb=>acswupb            0   t,y,x accumulated all-sky upward surface shortwave radiation flux[W/m²]
acswdntc=>acswdntc          0   t,y,x accumulated clear-sky downward top-of-atmosphere shortwave radiation flux
acswdnt=>acswdnt            0   t,y,x accumulated all-sky downward top-of-atmosphere shortwave radiation flux[W/m²]
acswdnbc=>acswdnbc          0   t,y,x accumulated clear-sky downward surface shortwave radiation flux[W/m²]
acswdnb=>acswdnb            0   t,y,x accumulated all-sky downward surface shortwave radiation flux[W/m²]
olrtoa=>olrtoa              0   t,y,x all-sky top-of-atmosphere outgoing longwave radiation flux[W/m²]
cldfrac_tot_UPP=>cldf       0   t,y,x Total cloud fraction using UPP column max method
lh=>lh                      0   t,y,x upward latent heat flux at the surface [W m^{-2}]
hfx=>hfx                    0   t,y,x upward heat flux at the surface [W m^{-2}]
alh=>clsf                   0   t,y,x accumulated latent heat flux at the surface [W m^{-2}]
ahfx=>cssf                  0   t,y,x accumulated upward heat flux at the surface [W m^{-2}]
ivgtyp=>ivgtyp              0     y,x  dominant vegetation category
sst=>sst                    0   t,y,x  sea-surface temperature
xice=>xice                  0   t,y,x  fractional area coverage of sea-ice
prec=>prec                  0   t,y,x  total preciptation
prcv=>prcv                  0   t,y,x  convective precipitation
spmt=>spmt                  0   t,y,x  Time Mean sea-level pressure
sfc_runoff=>srunoff         0   t,y,x  Time Mean surface runoff      [mm]
udr_runoff=>urunoff         0   t,y,x  Time Mean underground runoff  [mm]
sms_total=>sms              0   t,y,x  Time Mean total soil mositure    [mm]
smois_lys01=>smois01        0   t,y,x  Time Mean soil moisture layers01 [m^3 m^-3]
smois_lys02=>smois02        0   t,y,x  Time Mean soil moisture layers02 [m^3 m^-3
smois_lys03=>smois03        0   t,y,x  Time Mean soil moisture layers03 [m^3 m^-3]
smois_lys04=>smois04        0   t,y,x  Time Mean soil moisture layers04 [m^3 m^-3]
tslb_lys01=>tslb01          0   t,y,x  Time Mean soil layer temperature layers01[K]
tslb_lys02=>tslb02          0   t,y,x  Time Mean soil layer temperature layers02[K]
tslb_lys03=>tslb03          0   t,y,x  Time Mean soil layer temperature layers03[K]
tslb_lys04=>tslb04          0   t,y,x  Time Mean soil layer temperature layers04[K]
h_pbl=>hpbl                 0   t,y,x  Time Mean Planetary Boundary Layer (PBL) height [m]
qke_isobaric=>qke          27 t,z,y,x Time Mean twice turbulent kinetic energy [m^{2} s^{-2}]
kzh_isobaric=>kzh          27 t,z,y,x Time Mean vertical diffusion coefficient of potential temperature [m^{2} s^{-1}]
kzm_isobaric=>kzm          27 t,z,y,x Time Mean vertical diffusion coefficient of mommentum [m^{2} s^{-1}]
kzq_isobaric=>kzq          27 t,z,y,x Time Mean vertical diffusion coefficient of water vapor and cloud condensates
t02mt=>t02mt                0   t,y,x Time Mean 2-meter temperature [K]
q02mt=>q02mt                0   t,y,x Time Mean 2-meter specific humidity [kg kg^{-1}]
u10mt=>u10mt                0   t,y,x Time Mean 10-meter zonal wind [m s^{-1}]
v10mt=>v10mt                0   t,y,x Time Mean 10-meter meridional wind[m s^{-1}]
acrefl10cm_max=>refmax        0   t,y,x Time Mean 10 cm maximum radar reflectivity  [dBZ]
acrefl10cm_1km=>ref1km        0   t,y,x Time Mean diagnosed 10 cm radar reflectivity at 1 km AGL [dBZ]
acrefl10cm_1km_max=>ref1kmmax 0   t,y,x Time Mean maximum diagnosed 10 cm radar reflectivity at 1 km AGL since last output time [dBz]
ENDVARS
EOF1

sed '15 r '${pathin}'/latitude.tmp' ${pathin}/file.ctl > ${pathin}/file.tmp0
sed '13 r '${pathin}'/longitude.tmp' ${pathin}/file.tmp0 > ${pathin}/template.ctl

rm -f ${pathin}/file.*
}

