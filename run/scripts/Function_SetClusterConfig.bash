#!/bin/bash -x

function Function_SetClusterConfig() {
local  EXP_RES=$1
local  TypeGrid=${2}        #TypeGrid=variable_resolution
local  mensage=$3
echo ${mensage}
if [ ${TypeGrid} = 'variable_resolution' ]; then
#
# selected ncores to submission job
#

case "`echo ${EXP_RES} | awk '{print $1/1 }'`" in
  835586)cores_model=512 ;nodes_model=4 ;cores=256 ;cores_stat=32   ;nodes=2 ;; 	   #'060_003km' ;; 
  535554)cores_model=256 ;nodes_model=2 ;cores=32  ;cores_stat=32   ;nodes=1 ;; 	   # 060_015km
  163842)cores_model=128 ;nodes_model=1 ;cores=32  ;cores_stat=32   ;nodes=1 ;; 	   # 060_015km
esac
#
# Configuracoes
#
JobElapsedTime=01:00:00   # Tempo de duracao do Job
MPITasks=${cores}         # Numero de processadores que serao utilizados no Job
TasksPerNode=${cores}     # Numero de processadores utilizados por tarefas MPI
ThreadsPerMPITask=1       # Number of cores hosting OpenMP threads

else

case "`echo ${EXP_RES} | awk '{print $1/1 }'`" in
65536002)cores_model=514 ;nodes_model=4 ;cores=256 ;cores_stat=32  ;nodes=2 ;;
 2621442)cores_model=256 ;nodes_model=2 ;cores=128 ;cores_stat=32  ;nodes=1 ;; 
 1024002)cores_model=128 ;nodes_model=1 ;cores=32  ;cores_stat=32  ;nodes=1 ;;     
  655362)cores_model=48  ;nodes_model=1 ;cores=48  ;cores_stat=32  ;nodes=1 ;; 
  256002)cores_model=20  ;nodes_model=1 ;cores=20  ;cores_stat=32  ;nodes=1 ;; 
  163842)cores_model=16  ;nodes_model=1 ;cores=16  ;cores_stat=32  ;nodes=1 ;; 
   40962)cores_model=128 ;nodes_model=1 ;cores=128 ;cores_stat=32  ;nodes=1 ;; 
   10242)cores_model=8   ;nodes_model=1 ;cores=8   ;cores_stat=32  ;nodes=1 ;; 
    4002)cores_model=6   ;nodes_model=1 ;cores=6   ;cores_stat=32  ;nodes=1 ;; 
    2562)cores_model=2   ;nodes_model=1 ;cores=2   ;cores_stat=32  ;nodes=1 ;; 
esac
#
# Configuracoes
#
JobElapsedTime=01:00:00   # Tempo de duracao do Job
MPITasks=${cores}         # Numero de processadores que serao utilizados no Job
TasksPerNode=${cores}     # Numero de processadores utilizados por tarefas MPI
ThreadsPerMPITask=1       # Number of cores hosting OpenMP threads

fi

if [ "${MPITasks}" = "" ]; then
echo "ERROR Function_SetClusterConfig ${EXP_RES}=>"${RES_KM}
exit 5
fi
}
