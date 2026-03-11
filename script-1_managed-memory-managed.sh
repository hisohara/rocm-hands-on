#!/bin/bash
#PBS -A EDU3
#PBS -q edu1
#PBS -l walltime=00:10:00
#PBS -m n
#PBS -j oe
#PBS -o LOG_managed-memory-managed.log

module load rocm/7.2.0

cd $PBS_O_WORKDIR
cd rocm-hands-on/third_party/HPCTrainingExamples/ManagedMemory
cd Managed_Memory_Code

echo "### HSA_XNACK=1"
HSA_XNACK=1 ./gpu_code
echo
echo "### HSA_XNACK=0"
HSA_XNACK=0 ./gpu_code
