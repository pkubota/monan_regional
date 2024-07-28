#!/bin/bash -x
path_prefix_in="/mnt/beegfs/paulo.kubota/monan_regional"
path_prefix_out=`cd ..;pwd`

# Define a function with local variables

copy_mesh_quasi_uniform() {
  local path_in=${1}/pre/databcs/meshes/quasi_uniform/global/015_km
  local path_out=${2}/pre/databcs/meshes/quasi_uniform/global/015_km

  echo "cp -urfp: ${path_in} ${path_in}"
  
  cp -urfp ${path_in}/* ${path_out}/

  local path_in=${1}/pre/databcs/meshes/quasi_uniform/global/024_km
  local path_out=${2}/pre/databcs/meshes/quasi_uniform/global/024_km

  echo "cp -urfp: ${path_in} ${path_in}"
  
  cp -urfp ${path_in}/* ${path_out}/

}

# Define a function with local variables

copy_mesh_variable_resolution() {
  local path_in=${1}/pre/databcs/meshes/variable_resolution/global/060_015km
  local path_out=${2}/pre/databcs/meshes/variable_resolution/global/060_015km

  echo "cp -urfp: ${path_in} ${path_in}"
  
  cp -urfp ${path_in}/* ${path_out}/

  local path_in=${1}/pre/databcs/meshes/variable_resolution/global/092_025km
  local path_out=${2}/pre/databcs/meshes/variable_resolution/global/092_025km

  echo "cp -urfp: ${path_in} ${path_in}"
  
  cp -urfp ${path_in}/* ${path_out}/

}

# Define a function with local variables

copy_mesh_WPS_GEOG() {
  local path_in=${1}/pre/databcs/WPS_GEOG
  local path_out=${2}/pre/databcs/WPS_GEOG

  echo "cp -urfp: ${path_in} ${path_in}"
  
  mkdir -p ${path_out}/
  cd ${path_out}/
  ln -s ${path_in}/* .
}


# Define a function with local variables

copy_mesh_datain_gfs() {
  local path_in=${1}/pre/datain/regional/gfs/
  local path_out=${2}/pre/datain/regional/gfs/

  echo "cp -urfp: ${path_in} ${path_in}"
  
  cp -urfp ${path_in}/* ${path_out}/

  local path_in=${1}/pre/datain/global/gfs/
  local path_out=${2}/pre/datain/global/gfs/

  echo "cp -urfp: ${path_in} ${path_in}"
  
  cp -urfp ${path_in}/* ${path_out}/

}

# Define a function with local variables

copy_mesh_datain_era5() {
  local path_in=${1}/pre/datain/regional/era5/
  local path_out=${2}/pre/datain/regional/era5/

  echo "cp -urfp: ${path_in} ${path_in}"
  
  cp -urfp ${path_in}/* ${path_out}/

  local path_in=${1}/pre/datain/global/era5/
  local path_out=${2}/pre/datain/global/era5/

  cp -urfp ${path_in}/* ${path_out}/

}

# Define a function with local variables

copy_mesh_exec() {
  local path_in=${1}/pre/exec
  local path_out=${2}/pre/exec

  echo "cp -urfp: ${path_in} ${path_in}"
  
  cp -urfp ${path_in}/* ${path_out}/
}

# Define a function with local variables

copy_mesh_tables() {
  local path_in=${1}/pre/tables/
  local path_out=${2}/pre/tables/

  echo "cp -urfp: ${path_in} ${path_in}"
  
  cp -urfp ${path_in}/* ${path_out}/
}
copy_mesh_quasi_uniform       ${path_prefix_in}  ${path_prefix_out}
copy_mesh_variable_resolution ${path_prefix_in}  ${path_prefix_out}
copy_mesh_WPS_GEOG            ${path_prefix_in}  ${path_prefix_out}
copy_mesh_datain_gfs          ${path_prefix_in}  ${path_prefix_out}
copy_mesh_datain_era5         ${path_prefix_in}  ${path_prefix_out}
copy_mesh_exec                ${path_prefix_in}  ${path_prefix_out}
copy_mesh_tables              ${path_prefix_in}  ${path_prefix_out}
