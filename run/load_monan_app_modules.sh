module purge
module load gnu9/9.4.0
module load ohpc
module unload openmpi4
module load phdf5
module load netcdf
module load netcdf-fortran
module load mpich-4.0.2-gcc-9.4.0-gpof2pv
module load hwloc
module load cdo-2.0.4-gcc-9.4.0-bjulvnd
module load opengrads-2.2.1
module load anaconda3-2022.05-gcc-11.2.0-q74p53i 
module load imagemagick-7.0.8-7-gcc-11.2.0-46pk2go
module list

export OMP_NUM_THREADS=1
export OMPI_MCA_btl_openib_allow_ib=1
export OMPI_MCA_btl_openib_if_include="mlx5_0:1"
export PMIX_MCA_gds=hash

export NETCDF=/mnt/beegfs/monan/libs/netcdf
export PNETCDF=/mnt/beegfs/monan/libs/PnetCDF

export NCARG_ROOT=/home/paulo.kubota/.conda/envs/ncl_stable
export NCARG_BIN=${NCARG_ROOT}/bin
export PATH=${NCARG_BIN}:${PATH}

MPI_PARAMS="-iface ib0 -bind-to core -map-by core"
export MKL_NUM_THREADS=1
export I_MPI_DEBUG=5
export MKL_DEBUG_CPU_TYPE=5
export I_MPI_ADJUST_BCAST=12 ## NUMA aware SHM-Based (AVX512)

