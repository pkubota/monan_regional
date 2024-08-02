#!/bin/bash -x

function Function_SetResolution() {
local  EXP_RES=$1
local  TypeGrid=${2}        #TypeGrid=variable_resolution
local  mensage=$3
echo ${mensage}

#  os tamanhos dos intervalos de tempo geralmente recebem o valor de 6x do espaçamento da grade em km.

if [ ${TypeGrid} = 'variable_resolution' ]; then

case "`echo ${EXP_RES} | awk '{print $1/1 }'`" in
  835586)dt_step=12  ;RES_KM='060_003km';frac=20;len_disp=3000  ;; 
  535554)dt_step=90  ;RES_KM='060_015km';frac=4 ;len_disp=15000 ;; 
  163842)dt_step=150 ;RES_KM='092_025km';frac=4 ;len_disp=25000 ;; 
esac

else

case "`echo ${EXP_RES} | awk '{print $1/1 }'`" in
65536002)dt_step=12  ;RES_KM='003_km';frac=1;len_disp=3000   ;;
 2621442)dt_step=90  ;RES_KM='015_km';frac=1;len_disp=15000  ;; 
 1024002)dt_step=150 ;RES_KM='024_km';frac=1;len_disp=24000  ;; 
  655362)dt_step=240 ;RES_KM='030_km';frac=1;len_disp=30000  ;; 
  256002)dt_step=300 ;RES_KM='048_km';frac=1;len_disp=48000  ;; 
  163842)dt_step=360 ;RES_KM='060_km';frac=1;len_disp=60000  ;; 
   40962)dt_step=720 ;RES_KM='120_km';frac=1;len_disp=120000 ;; 
   10242)dt_step=900 ;RES_KM='240_km';frac=1;len_disp=240000 ;; 
    4002)dt_step=1800;RES_KM='384_km';frac=1;len_disp=384000 ;; 
    2562)dt_step=1800;RES_KM='480_km';frac=1;len_disp=480000 ;; 
esac
fi

if [ "${RES_KM}" = "" ]; then
echo "ERROR Function_SetResolution ${EXP_RES}=>"${RES_KM}
exit 3
fi
}
