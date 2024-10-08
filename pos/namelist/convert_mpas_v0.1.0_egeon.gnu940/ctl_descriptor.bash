#!/bin/bash

# TODO - revision history - start from last GAM rev - this is a different code purpose

function usage(){
   sed -n '/^# !CALLING SEQUENCE:/,/^# !/{p}' ./post.bash | head -n -1
}

#
# Verificando argumentos de entrada
#

if [ $# -ne 3 ]; then
   usage
   exit 1
fi
EXP_NAME=${1}
EXP_RES=${2}
LABELI=${3} 


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


cat<<EOF1>template.ctl
DSET ^mpas.%y4-%m2-%d2_%h2.00.00.nc

DTYPE netcdf

Options zrev template

TITLE Ocean Surface Variables

UNDEF -9.99e+08

*UNPACK scale_factor add_offset

XDEF 720 linear    0.0  0.5

YDEF  360 linear  -89.875 0.5

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
precipw=>agpl               0   t,y,x precipitable water [kg/m�]
aclwuptc=>aclwuptc          0   t,y,x accumulated clear-sky upward top-of-the-atmosphere longwave radiation flux [W/m�]
aclwupt=>aclwupt            0   t,y,x accumulated all-sky upward top-of-the-atmosphere longwave radiation flux  [W/m�]
aclwupbc=>aclwupbc          0   t,y,x accumulated clear-sky upward surface longwave radiation flux[W/m�]
aclwupb=>aclwupb            0   t,y,x accumulated all-sky upward surface longwave radiation flux [W/m�]
aclwdntc=>aclwdntc          0   t,y,x accumulated clear-sky downward top-of-the-atmosphere longwave radiation flux[W/m�]
aclwdnt=>aclwdnt            0   t,y,x accumulated all-sky downward top-of-the-atmosphere longwave radiation flux [W/m�]
aclwdnbc=>aclwdnbc          0   t,y,x accumulated clear-sky downward surface longwave radiation flux[W/m�]
aclwdnb=>aclwdnb            0   t,y,x accumulated all-sky downward surface longwave radiation flux[W/m�]
acswuptc=>acswuptc          0   t,y,x accumulated clear-sky upward top-of-atmosphere shortwave radiation flux[W/m�]
acswupt=>acswupt            0   t,y,x accumulated all-sky upward top-of-atmosphere shortwave radiation flux [W/m�]
acswupbc=>acswupbc          0   t,y,x accumulated clear-sky upward surface shortwave radiation flux[W/m�]
acswupb=>acswupb            0   t,y,x accumulated all-sky upward surface shortwave radiation flux[W/m�]
acswdntc=>acswdntc          0   t,y,x accumulated clear-sky downward top-of-atmosphere shortwave radiation flux
acswdnt=>acswdnt            0   t,y,x accumulated all-sky downward top-of-atmosphere shortwave radiation flux[W/m�]
acswdnbc=>acswdnbc          0   t,y,x accumulated clear-sky downward surface shortwave radiation flux[W/m�]
acswdnb=>acswdnb            0   t,y,x accumulated all-sky downward surface shortwave radiation flux[W/m�]
olrtoa=>olrtoa              0   t,y,x all-sky top-of-atmosphere outgoing longwave radiation flux[W/m�]
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
