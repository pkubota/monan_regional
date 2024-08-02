#!/bin/bash 
#
# 1. Timeseries for Diagnostic fields
#
rm -f include_fields
cp include_fields.diag include_fields
rm -f latlon.nc surface.nc
exit
./convert_mpas ../monanprd/x1.1024002.init.nc ../monanprd/diag*nc

cdo settunits,hours -settaxis,2021-01-01,00:00,1hour latlon.nc surface.nc

rm -f latlon.nc

#
# 2. Timeseries for History fields
#

rm -f include_fields wind+pw_sfc.nc
cp include_fields.history include_fields
./convert_mpas ../monanprd/x1.1024002.init.nc ../monanprd/history.*.nc

cdo settunits,hours -settaxis,2021-01-01,00:00,3hour latlon.nc wind+pw_sfc.nc

rm -f latlon.nc 

#
# 3.  
#
./convert_mpas ../monanprd/history.2021-01-02_00.00.00.nc

#cdo -setreftime,1900-01-01,00:00:00,1day -setdate,1900-01-01 -setcalendar,standard latlon.nc history.2021-01-04_00.00.00.nc

# 24h
cdo settunits,hours -settaxis,2021-01-02,00:00,3hour latlon.nc history.2021-01-02_00.00.00.nc

rm -f latlon.nc

exit 0
