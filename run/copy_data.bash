#!/bin/bash -x
path_prefix_in="/mnt/beegfs/paulo.kubota/monan_project/MPAS_Model_Regional"
path_prefix_out="/mnt/beegfs/paulo.kubota/monan_regional"
#${path_prefix_in}/pre/databcs/meshes/quasi_uniform/global/015_km
#${path_prefix_out}/pre/databcs/meshes/quasi_uniform/global/015_km

# Define a function with local variables

copy_mesh_quasi_uniform() {
  local path_in=${1}/pre/databcs/meshes/quasi_uniform/global/015_km
  local path_out=${2}/pre/databcs/meshes/quasi_uniform/global/015_km

  echo "cp -urfp: ${path_in} ${path_in}"
  
  cp -urfp ${path_in}/* ${path_out}/
}

# Define a function with local variables

copy_mesh_variable_resolution() {
  local path_in=${1}/pre/databcs/meshes/variable_resolution/global/060_015km
  local path_out=${2}/pre/databcs/meshes/variable_resolution/global/060_015km

  echo "cp -urfp: ${path_in} ${path_in}"
  
  cp -urfp ${path_in}/* ${path_out}/
}


# Define a function with local variables

copy_mesh_WPS_GEOG() {
  local path_in=${1}/pre/databcs/WPS_GEOG
  local path_out=${2}/pre/databcs/WPS_GEOG

  echo "cp -urfp: ${path_in} ${path_in}"
  
  cp -urfp ${path_in}/* ${path_out}/
}

copy_mesh_quasi_uniform       ${path_prefix_in}  ${path_prefix_out}
copy_mesh_variable_resolution ${path_prefix_in}  ${path_prefix_out}
copy_mesh_WPS_GEOG            ${path_prefix_in}  ${path_prefix_out}
