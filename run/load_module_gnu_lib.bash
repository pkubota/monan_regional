#! /bin/bash -x
module purge
module load gnu9
module load openmpi4/4.1.1
##module load netcdf-fortran/4.5.3
# Environment settings to run a MPI/OpenMP parallel program compiled with Intel
# MPI
#export I_MPI_PMI_LIBRARY=/usr/lib64/libpmi.so
#unset I_MPI_PMI_LIBRARY
#export I_MPI_JOB_RESPECT_PROCESS_PLACEMENT=0   # the option -ppn only works if you set this before
#export USE_PIO2=true
export NETCDF='/mnt/beegfs/paulo.kubota/lib/netcdf'
export PNETCDF='/mnt/beegfs/paulo.kubota/lib/pnetcdf-1.12.3/PnetCDF'
export PIO='/mnt/beegfs/paulo.kubota/lib/pio-2.5.4'
export HDF_DIR=/mnt/beegfs/paulo.kubota/lib/hdf5-1.12.1
export WRFIO_NCD_LARGE_FILE_SUPPORT=0
export WRF_EM_CORE=0
export WRF_NMM_CORE=0
export WRF_DA_CORE=0
export WRF_CHEM=0
export MP_STACK_SIZE=64000000
export PATH=${PATH}:/mnt/beegfs/paulo.kubota/lib/openjpeg:/mnt/beegfs/paulo.kubota/lib/netcdf/bin:/mnt/beegfs/paulo.kubota/lib/hdf5-1.12.1:/mnt/beegfs/paulo.kubota/lib/hdf5-1.12.1/bin
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/mnt/beegfs/paulo.kubota/lib/grib2/lib:/mnt/beegfs/paulo.kubota/lib/openjpeg/lib:/mnt/beegfs/paulo.kubota/lib/grib2/lib:/mnt/beegfs/paulo.kubota/lib/libaec/libaec-v0.3.2/lib:/mnt/beegfs/paulo.kubota/lib/hdf5-1.12.1/lib:/mnt/beegfs/paulo.kubota/lib/hdf5-1.12.1/include:/mnt/beegfs/paulo.kubota/lib/netcdf/lib:/mnt/beegfs/paulo.kubota/lib/netcdf/include
export AEC_LIBRARY='/mnt/beegfs/paulo.kubota/lib/libaec/libaec-v0.3.2/lib'
export AEC_INCLUDE_DIR='/mnt/beegfs/paulo.kubota/lib/libaec/libaec-v0.3.2/include'
export JASPERLIB='/mnt/beegfs/paulo.kubota/lib/grib2/lib'
export JASPERINC='/mnt/beegfs/paulo.kubota/lib/grib2/include'
export JASPER_INCLUDE_DIR='/mnt/beegfs/paulo.kubota/lib/grib2/include/jasper'
export OPENJPEG_LIBRARY='/mnt/beegfs/paulo.kubota/lib/openjpeg/lib'
export OPENJPEG_INCLUDE_DIR='/mnt/beegfs/paulo.kubota/lib/openjpeg/include'
ulimit -s unlimited
